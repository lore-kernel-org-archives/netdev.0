From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Routing 600+ vlan's via linux problems (looks like arp
 problems)
Date: Thu, 3 May 2007 14:38:32 -0700
Message-ID: <20070503143832.17a08fbb@freekitty>
References: <d20c3b7d0705031325r13834382r38ea31f26965c50@mail.gmail.com>
	<20070503205346.GD18539@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?w5h5dmluZCBWw6VnZW4gSsOmZ3RuZXM=?= <lorrides@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:32815 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161441AbXECVip convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 17:38:45 -0400
In-Reply-To: <20070503205346.GD18539@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 May 2007 22:53:46 +0200
Sam Ravnborg <sam@ravnborg.org> wrote:

> On Thu, May 03, 2007 at 10:25:48PM +0200, =C3=98yvind V=C3=A5gen J=C3=
=A6gtnes wrote:
> > Hi,
> Hi =C3=98yvind.
>=20
> Forwarding your mail to netdev where the networking people are
> hanging out. Maybe they can help you.
>=20
> 	Sam
>=20
> >=20
> > We have a one gigabit internet connection that is normally
> > routed by a hardware juniper router. The drive in this is down
> > and we need to use a linux machine (Pentium D 3 ghz) as a
> > temporary router.
> > Now setting up all the 600 vlans and assigning ip addresses
> > is no problem. We have testet all by using a laptop, setting up
> > 600 vlan interfaces on this and running dhcpclient on all.
> > This worked just fine, all the interfaces got address.
> >=20
> > Now for the real setup.
> > We closed the mac of the juniper to the network card that
> > would be connected to the internal LAN, set up the interfaces,
> > and swapped cables. This worked fine for approximately 100
> > of the computers that are connected, but the rest would not
> > get IP. The connected 100 computers were routed just fine.
> >=20
> > What we think the problem is, is that the arp cache on the
> > linux router seems strange. It can resolve the MAC for the
> > 100 clients that actually got through.
> > For the rest all we see in the arp cache is (incomplete)
> >=20
> > Here is some of the listing for arp -n:
> > 193.239.155.118          ether   00:0A:E4:59:75:66   C
> > eth1.1087
> > 193.239.154.74                   (incomplete)
> > eth1.1016
> > 193.239.155.7            ether   00:11:95:D2:3F:FD   C
> > eth1.2002
> > 83.143.114.222                   (incomplete)
> > eth1.1305
> > 83.143.113.246           ether   00:0B:5D:4B:B8:77   C
> > eth1.1247
> > 83.143.116.126                   (incomplete)
> > eth1.1409
> > 83.143.118.114                   (incomplete)
> > eth1.1534
> > 193.239.154.210          ether   00:03:0D:2F:1B:7F   C
> > eth1.1050
> > 169.254.69.247           ether   00:15:C5:C2:31:6C   C
> > eth1.1262
> > 83.143.112.38                    (incomplete)
> > eth1.1131
> > 83.143.118.18                    (incomplete)
> > eth1.1510
> > 83.143.112.118           ether   00:11:95:CE:BF:72   C
> > eth1.1151
> > 192.168.1.2              ether   00:0D:88:78:C0:00   C
> > eth1.2050
> > 83.143.117.138                   (incomplete)
> > eth1.1476
> > 83.143.116.18                    (incomplete)
> > eth1.1382
> > 83.143.118.26                    (incomplete)
> > eth1.1512
> > 83.143.112.6                     (incomplete)
> > eth1.1123
> > 193.239.155.62                   (incomplete)
> > eth1.1073
> >=20
> > `arp -n|wc -l` returns around 350, which is the number of active po=
rts on=20
> > the
> > edge switches...
> > this number is confirmed by snmp
> >=20
> > I have looked through the source for arp.c but i can't see any imme=
diate
> > problems. There is no messages in dmesg, kern.log og messages (exce=
pt for
> > eth1.vlanid up * 600).
> >=20
> > If anyone know what the problem can be, if this is a bug, or if PSB=
KC i=20
> > would
> > much appreciate it.
> >=20
> > regards
> > =C3=98yvind V=C3=A5gen J=C3=A6gtnes
> > +47 96 22 03 08
> > lorrides@gmail.com

What kernel version?  Are you on a recent 2.6 kernel or stuck on some=20
old "vendor stable" 2.4 kernel?

--=20
Stephen Hemminger <shemminger@linux-foundation.org>
