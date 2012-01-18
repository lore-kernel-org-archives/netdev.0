From: Simon Chen <simonchennj@gmail.com>
Subject: Re: Wrong mac in arp response in bonded interfaces
Date: Wed, 18 Jan 2012 15:02:27 -0500
Message-ID: <CANj2EbfB+9HXPtZqAASVTWLJ0fxK28c4CcSTuVJGiLvKaMXUfg@mail.gmail.com>
References: <CANj2EbfW-YP41-=w+qGxfV-QMaBOxtijOKFDUt+o-kLsUbf1ag@mail.gmail.com>
	<12128.1326916050@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35931 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab2ARUC2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 15:02:28 -0500
Received: by wgbdq11 with SMTP id dq11so3623217wgb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 12:02:27 -0800 (PST)
In-Reply-To: <12128.1326916050@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond0 and the physical interfaces show up with the same mac in ifconfig=
=2E..

The latest founding between me and my co-worker is that the MAC
address of the bonded interface switches between :44 and :45. Because
we're using an automated deployment tool, which unfortunately doesn't
reliably configure the udev rules correctly to persistent the two
NICs. So after a re-deploy, the MAC for the bonded NIC may switch. And
the stale MAC entry on the switch is then preventing return packet to
be delivered successfully.

oh, boy, this is just fun... will see if this is indeed the issue.

On Wed, Jan 18, 2012 at 2:47 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Simon Chen <simonchennj@gmail.com> wrote:
>
>>Hi all,
>>
>>Something really weird with interface bonding...
>>
>>I have eth0 and eth1, with MAC address xx:44 and xx:45. The bonded
>>interface chose to use xx:45 as its MAC.
>>
>>I configured an IP on the bonded interface, and try to ping the
>>default gw. The ARP from the server for the .1 is answered by the GW.
>>The server then sends out ICMP to the GW. The problem is the GW is no=
t
>>responding to the ping.
>
> =A0 =A0 =A0 =A0How much real time is elapsing between the setting up =
of the
> bond, and this ping test? =A0What are the slaves set up as prior to t=
he
> bond being established? =A0In particular, is one of them (the :44)
> assigned the IP address that the bond ends up using?
>
>>I then logged onto the GW (a switch) - apparently, the ARP table on
>>the GW shows that my server's IP is associated with xx:44 MAC address=
=2E
>>So, actually the GW is responding the ICMP, just to the wrong MAC
>>dest.
>>
>>Any idea how the xx:44 MAC somehow polluted the ARP table on my GW?
>>How can I make sure my server always sends out packets with xx:45 MAC
>>via the bonded interface?
>
> =A0 =A0 =A0 =A0My first suspicion is that a stale ARP entry on the sw=
itch is
> hanging around for the :44 MAC address from before the bond was
> established on the host. =A0If you clear the switch's ARP table, does=
 the
> problem correct itself or happen again?
>
> =A0 =A0 =A0 =A0The other possibility that comes to mind is that you'r=
e using
> balance-alb mode, in which case I suspect what you're seeing is norma=
l
> behavior. =A0The alb mode "assigns" peers to particular slaves of the=
 bond
> by sending them tailored ARP messages bearing the MAC of one of the
> slaves, and each slave participates on the network under its own MAC
> address (I'm simplifying a bit here, but that's basically how it work=
s).
>
> =A0 =A0 =A0 =A0-J
>
> ---
> =A0 =A0 =A0 =A0-Jay Vosburgh, IBM Linux Technology Center, fubar@us.i=
bm.com
>
