From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <remi-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org>
Subject: Re: Trouble getting a stable miredo relay
Date: Thu, 12 Mar 2009 16:24:09 +0200
Message-ID: <200903121624.09972.remi@remlab.net>
References: <0A8C9460533C4688AD2B16D7CE94614E@intra.widexs.nl>
Reply-To: miredo-devel-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: miredo-devel-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org
Return-path: <miredo-devel-bounce-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org>
In-Reply-To: <0A8C9460533C4688AD2B16D7CE94614E-buZBqSF2HJSvtRW33yhrgg@public.gmane.org>
Content-Disposition: inline
Sender: miredo-devel-bounce-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org
Errors-to: miredo-devel-bounce-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org
List-Id: netdev.vger.kernel.org

	Hello,

Le jeudi 12 mars 2009 16:06:13 Wouter de Jong, vous avez =E9crit=A0:
> I'm trying to get a miredo relay up & running.
> While it should be so easy, I can't get it stable...

> After a very short period (< 5-10 minutes) of announcing 2001::/32
> via BGP to the rest of the world,
> I see a lot of packetloss towards hosts in our network that I reach
> through our relay from teredo clients.
> Sometimes the addresses are not reachable at all (not even the
> relay-address).

This is symptomatic of an overflow in the route/neighbor caches of the kern=
el.=20
Please try to increase the size (a lot) manually via sysctl. I don't know=20
anything sane userland/TUNTAP can do about this.

> From native IPv6 hosts from outside -> native IPv6 hosts inside our
> network and vice versa, there is no packetloss at all.

> I tried various hardware (SuperMicro Dual Xeon, Dell 860 Dual-Core
> machine, HP DL360, etc)... all ending up with the same result. Tried
> various distro's (CentOS 5.2, Fedora 10, Ubuntu server 8.10,
> Debian 4.0r7). Distro specific packages, self-compile (against Judy,
> without Judy).... no change.

> I tried separating the IPv4 traffic from the IPv6 traffic (both on
> different nic's), tried tweaking sysctl parameters .... all to no
> avail.=20

> At no point the relay took more than 10Mbit/s.

Miredo holds a paradoxical situation whereby it (in userland) can easily=20
handle millions of peers, but the kernel starts failing at 1024 of them.

See also=20
http://kerneltrap.org/mailarchive/linux-netdev/2008/8/31/3146914/thread and=
=20
http://kerneltrap.org/mailarchive/linux-netdev/2008/8/31/3147634/thread

You don't need much bandwidth to hit 1024 peers. You just to export your ro=
ute=20
to sufficiently many people. I don't know why there is a neighbors cache fo=
r=20
no-ARP interfaces in the first place. I guess nobody ever bothered to=20
conditionnaly disable the code.

> When I restart miredo, it usually works again for a minute (but not
> always).  With tcpdump i do see a lot of teredo traffic when it
> appears to give unreachable messages for hosts.

Best regards,

=2D-=20
R=E9mi Denis-Courmont
http://www.remlab.net/
