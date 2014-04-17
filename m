From: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 17 Apr 2014 13:47:01 -0400
Message-ID: <1397756821.2628.69.camel@willson.li.ssimo.org>
References: <20140416180642.GG31074@redhat.com>
	 <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
	 <20140416185936.GJ31074@redhat.com> <534FF61B.4010901@redhat.com>
	 <1397750674.2628.44.camel@willson.li.ssimo.org>
	 <CALCETrUrj2LtAoXp600BD2ANgE2UUEbTYQrK8hHqDR=qpeFPcg@mail.gmail.com>
	 <1397751853.2628.50.camel@willson.li.ssimo.org>
	 <CALCETrWNWvumFg9Qba0GEOjYop4WYe530tCPtakrhnoCrHqhUQ@mail.gmail.com>
	 <1397753323.2628.60.camel@willson.li.ssimo.org>
	 <CALCETrXj6kD3E+vsaWmkrSbaQYTu=c-Hsw640jh4O+FbojYk2g@mail.gmail.com>
	 <20140417171256.GB25334@redhat.com>
	 <CALCETrVq4HRpfWOAbZAQbyjuraQd=OxnW=WjSoe5JgBzRStiKg@mail.gmail.com>
	 <1397756025.2628.64.camel@willson.li.ssimo.org>
	 <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-04-17 at 10:35 -0700, Andy Lutomirski wrote:
> On Thu, Apr 17, 2014 at 10:33 AM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Thu, 2014-04-17 at 10:26 -0700, Andy Lutomirski wrote:
> >>
> >> Not really.  write(2) can't send SCM_CGROUP.  Callers of sendmsg(2)
> >> who supply SCM_CGROUP are explicitly indicating that they want their
> >> cgroup associated with that message.  Callers of write(2) and send(2)
> >> are simply indicating that they have some bytes that they want to
> >> shove into whatever's at the other end of the fd.
> >
> > But there is no attack vector that passes by tricking setuid binaries to
> > write to pre-opened file descriptors on sendmsg(), and for the other
> > cases (connected socket) journald can always cross check with
> > SO_PEERCGROUP, so why do we care again ?
> 
> Because the proposed code does not do what I described, at least as
> far I as I can tell.

You do realize that we have been speaking in hypothetical for a while
now ?

Even without doing the SO_PEERCRED, you are not going to fool the log,
as it gathers a ton of other info about the process, and cgroup is just
one of the infos used to classify the log.

There are also credentials, pid, and a lot of other things.
Even if a setuid binary could be tricked to send a message with an
"impostor" cgroup don't you think you'd see other things out of place ?
(wrong uid, wrong pid, etc...).

What I am telling you is that userspace has all the tools it needs to
not get fooled, as long as cgroup information retrieved via
SO_PASSCGROUP is not uniquely used to authenticate a peer process for
connected sockets.

Simo.
