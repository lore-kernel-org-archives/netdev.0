From: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [net-next PATCH v2 8/8] net: Introduce SO_INCOMING_NAPI_ID
Date: Thu, 23 Mar 2017 15:43:09 -0700
Message-ID: <CALCETrUD_+JcoAd7Z5+E+fNgeLOy=6-DYOoaRDWDViYd=dWQ=A@mail.gmail.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain> <20170323213802.12615.58216.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170323213802.12615.58216.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2017 at 2:38 PM, Alexander Duyck
<alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> From: Sridhar Samudrala <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
> This socket option returns the NAPI ID associated with the queue on which
> the last frame is received. This information can be used by the apps to
> split the incoming flows among the threads based on the Rx queue on which
> they are received.
>
> If the NAPI ID actually represents a sender_cpu then the value is ignored
> and 0 is returned.

This may be more of a naming / documentation issue than a
functionality issue, but to me this reads as:

"This socket option returns an internal implementation detail that, if
you are sufficiently clueful about the current performance heuristics
used by the Linux networking stack, just might give you a hint as to
which epoll set to put the socket in."  I've done some digging into
Linux networking stuff, but not nearly enough to have the slighest
clue what you're supposed to do with the NAPI ID.

It would be nice to make this a bit more concrete and a bit less tied
in Linux innards.  Perhaps a socket option could instead return a hint
saying "for best results, put this socket in an epoll set that's on
cpu N"?  After all, you're unlikely to do anything productive with
busy polling at all, even on a totally different kernel
implementation, if you have more than one epoll set per CPU.  I can
see cases where you could plausibly poll with fewer than one set per
CPU, I suppose.

Again, though, from the description, it's totally unclear what a user
is supposed to do.

--Andy
