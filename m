From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Wed, 16 Apr 2014 11:40:44 -0700
Message-ID: <CALCETrURhBXQaYYJiHq2svPqB3-K7kmgD2QUTT9LCjry=fukWA@mail.gmail.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <1397667766.19767.440.camel@willson.li.ssimo.org> <CALCETrU_yKQVZyVug25cxwQFjWJ7Zf20FY-6ht+RJifXtDdDWg@mail.gmail.com>
 <20140416183614.GH31074@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140416183614.GH31074-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 11:36 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Apr 16, 2014 at 10:29:08AM -0700, Andy Lutomirski wrote:
>
> [..]
>> >> Admittedly cgroups aren't currently as important as uid, but if this
>> >> changes, then SO_PASSCGROUP, as currently written, will have *exactly*
>> >> the same problem.
>> >
>> > Which is easy to foil by using SO_PEERCGROUP and find out who originally
>> > opened the socket, which is why that is also available!
>>
>> Then please remove SO_PASSCGROUP.
>
> SO_PASSCGROUP is important because SO_PEERCGROUP does not work with unix
> datagram sockets.

Right.  I forgot about that.

>
> Again going back to logging example, if some clients are logging to unix
> datagram sockets, SO_PASSCGROUP is the only option to figure out cgroup
> of client.

Hmm.  I think that, in your patch, the cgroup that is sent is the
cgroup of the caller of write/send/sendmsg.  What if you changed it to
use the same cgroup that SO_PEERCRED would use?  Would that still
work?

>>
>> I still haven't seen any explanation for what's wrong with requiring
>> senders to ask the kernel to transmit their cgroup.
>
> If nothing else, additional complexity and ovhead. Extra pair of messages
> need to be exchanged to request and then provide the information.
>
> How would it work in logging example? Every time logger receives a
> message, is it supposed to send another message to client to send
> SCM_CGROUP? That does not sound right.

No -- just have the logger send the cgroup with every message.  Yes,
it seems silly, but it's probably barely more expensive than with the
code in your patch.

--Andy
