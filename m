From: jamal <hadi@cyberus.ca>
Subject: Re: [nf-failover] Re: [1/2] CARP implementation. HA master's
	failover.
Date: 20 Jul 2004 10:24:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090333462.1136.58.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
	 <1089907622.1027.48.camel@jzny.localdomain>
	 <1089910760.6114.967.camel@uganda>
	 <1089912285.1028.93.camel@jzny.localdomain>
	 <20040715235313.69897131@zanzibar.2ka.mipt.ru>
	 <1089983064.1060.1328.camel@jzny.localdomain>
	 <1090221367.2551.27.camel@nienna.balabit>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com,
        Netfilter-failover list <netfilter-failover@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: KOVACS Krisztian <hidden@balabit.hu>
In-Reply-To: <1090221367.2551.27.camel@nienna.balabit>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-07-19 at 03:16, KOVACS Krisztian wrote:
>   Hi,
>=20
> 2004-07-16, p keltez=E9ssel 15:04-kor jamal ezt =EDrta:
> > Looking at what HArald has, the infrastructure seems to be the correc=
t
> > flavor. Seems something gets sent to user space via netlink and gets
> > delivered via keepalived.
>=20
>   Unfortunately this is not the case, as Evgeniy already mentioned.
> ct_sync is currently an completely in-kernel solution, with all the pro=
s
> and cons of that. (Yes, it could be done in userspace with some minimal
> kernel code, and yes, it had a few advantages over the current solution.
> However, the kernel-side "agent" code would still be quite heavy-weight.
> Unfortunately Netfilter's conntrack subsystem is a more complicated tha=
n
> that of OpenBSD's pf. And the current code is not designed that way, so
> I think it would be better to first try to finish the current project,
> and then think about what should be done in a completely different way.=
)

Thats fine. So you may have to use Evgeniys in-kernel implementation for
now until things get better. How do you interact to keepalived?

> > I think the CARP loadbalancing feature is an improvement over what is
> > being suggested by Harald.
>=20
>   What do you mean by that? Of course, it is a serious weakness of the
> current code that it is not capable of load balancing, only failover
> with passive slaves. However, load balancing would probably make things
> a lot more complicated. For example, see NAT-related problems described
> by Lennert Buytenhek here:
>=20
> http://lists.netfilter.org/pipermail/netfilter-failover/2001-September/=
000043.html

i couldnt access that for some reason. Seems the wifi firewall is
blocking any web access.
What i meant was CARP with that feature infact has an active-active
setup - ct_snyc seems to be purely active-backup.

> > I have to say as well i am shocked that state is just being transfere=
d
> > blindly - but i will deal with Harald when he shows up in Ottawa ;->
>=20
>   Would it be possible to summarize your ideas here? Yes, I know it is
> easier and faster to talk about those things in person, but
> unfortunately I won't be there in Ottawa, but am of course seriously
> interested in all ideas related to ct_sync...

I talked briefly to Harald in the hallway and will attend his talk. I
may understand a little more about ct_sync - and hopefully a lot more
after his talk.

My comments were based on the fact that most flows are really
shortlived that there is no point in backing them up. Human nature
on a web page that is taking too long to load (for example because the
firewall failed) is to hit reload button - in which case the connection
tracking will be established from the begining with the failed over to
node. I will try to post a paper or two that have results on lifetimes
of flows etc when i have better network connection. What i remember
from one is that the majority of flows dont last longer than 10 secs
to begin with.=20

So back to what i was saying earlier, and my .ca $0.02:
If the majority of the flows are only lasting that long, is there=20
any value in backing them? One arguement i can see made is that you want
to speed up the lookup etc when 100K flows migrate to the backed-to
node.
my opinion is the following:
1)  it would be valuable to backup the rules if any exist and sync
things across.=20
2) dont blindly migrate connection states until they are established and
probably lasted more than 10-15 seconds.

cheers,
jamal
