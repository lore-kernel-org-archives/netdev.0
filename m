From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [nf-failover] Re: [1/2] CARP implementation. HA master's
	failover.
Date: Mon, 19 Jul 2004 09:16:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090221367.2551.27.camel@nienna.balabit>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
	 <1089907622.1027.48.camel@jzny.localdomain>
	 <1089910760.6114.967.camel@uganda>
	 <1089912285.1028.93.camel@jzny.localdomain>
	 <20040715235313.69897131@zanzibar.2ka.mipt.ru>
	 <1089983064.1060.1328.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com,
        Netfilter-failover list <netfilter-failover@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089983064.1060.1328.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


  Hi,

2004-07-16, p keltez=E9ssel 15:04-kor jamal ezt =EDrta:
> Looking at what HArald has, the infrastructure seems to be the correct
> flavor. Seems something gets sent to user space via netlink and gets
> delivered via keepalived.

  Unfortunately this is not the case, as Evgeniy already mentioned.
ct_sync is currently an completely in-kernel solution, with all the pros
and cons of that. (Yes, it could be done in userspace with some minimal
kernel code, and yes, it had a few advantages over the current solution.
However, the kernel-side "agent" code would still be quite heavy-weight.
Unfortunately Netfilter's conntrack subsystem is a more complicated than
that of OpenBSD's pf. And the current code is not designed that way, so
I think it would be better to first try to finish the current project,
and then think about what should be done in a completely different way.)

> I think the CARP loadbalancing feature is an improvement over what is
> being suggested by Harald.

  What do you mean by that? Of course, it is a serious weakness of the
current code that it is not capable of load balancing, only failover
with passive slaves. However, load balancing would probably make things
a lot more complicated. For example, see NAT-related problems described
by Lennert Buytenhek here:

http://lists.netfilter.org/pipermail/netfilter-failover/2001-September/00=
0043.html

> I have to say as well i am shocked that state is just being transfered
> blindly - but i will deal with Harald when he shows up in Ottawa ;->

  Would it be possible to summarize your ideas here? Yes, I know it is
easier and faster to talk about those things in person, but
unfortunately I won't be there in Ottawa, but am of course seriously
interested in all ideas related to ct_sync...

--=20
 Regards,
   Krisztian KOVACS
