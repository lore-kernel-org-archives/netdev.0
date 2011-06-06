From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multicast IP packet routed between 2 ports nic on the same host
Date: Mon, 06 Jun 2011 16:09:02 +0200
Message-ID: <1307369342.3098.26.camel@edumazet-laptop>
References: <24665DDC0D7CF047BD6471A56E615EA628ABF4DE@CA-OPS-MAILBOX.miranda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: BONNEAU Guy <gbonneau@miranda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52588 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab1FFOJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 10:09:06 -0400
Received: by wya21 with SMTP id 21so2813397wya.19
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 07:09:04 -0700 (PDT)
In-Reply-To: <24665DDC0D7CF047BD6471A56E615EA628ABF4DE@CA-OPS-MAILBOX.miranda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 13:40 +0000, BONNEAU Guy a =C3=A9crit :
> I am trying to receive multicast data packets from a multicast router
> to my Linux Ubuntu Desktop Workstation using kernel 2.6.35. The Linux
> Desktop has an Intel 82576 dual NIC adapter. Each NIC is configured t=
o
> receive IP data from 2 different subnet. One is from 172.30.8.xx and
> another one from 10.0.xx.xx. Multicast IP data can only be received
> from 172.30.8.xx since there is no multicast source on subnet
> 10.0.xx.xx and IT that administrates the subnet 10.0.xx.xx disabled
> multicast capability of the switches and routers sitting on that
> subnet. The subnet 172.30.8.xx has multicast source broadcasting on
> multicast group 239.255.200.200:8000.=20
>=20

Hi

Not clear if eth0 and eth1 are on both networks ?

Please send us

ip link
ip addr
ip ro

Thanks

> I am using the application mreceived (version 2.2) from :
> http://www.cs.virginia.edu/~mngroup/software/ to test the network
> multicast set-up and capability of my Ubuntu Desktop Workstation.=20
>=20
> I open a first console and I use mreceive to join multicast group
> 239.255.200.200:8000 to receive multicast data from subnet 10.0.xx.xx
> using the console command : ./mreceive -g 239.255.200.200 -p 8000 -i
> 10.0.9.164 to the eth0 adapter of my workstation. The application is
> idle and no multicast data is received. This is the expected
> behaviour.
>=20
> I open a second console and I use mreceive to join the same multicast
> group 239.255.200.200:8000 to receive multicast data from subnet
> 172.30.8.xx using the console command : ./mreceive -g 239.255.200.200
> -p 8000 -i 172.30.8.31 to the eth1 adapter of my workstation. The
> application starts to receive multicast data and advertises the data
> received. This is also the expected behaviour.
>=20
> Now this is where the problem begins. As soon as the multicast data
> begin to be received on the eth1 adapter the first console begins to
> advertise multicast data received on eth0 adapter. I am well aware
> that the Linux kernel implements a multicast level 2 routing
> capability. Thus at first glance this seems to be the expected
> behaviour. However... I have forwarding disabled as well as
> mc_forwarding disabled and rp_filter is enabled for both adapters.
> Thus I don't expect the kernel to forward the multicast data from eth=
1
> to eth0.=20
>=20
> I have recompiled the kernel with IP Multicast Routing disabled and
> got the same behavior. I also tried kernel 2.6.38 and had the same
> issue.
>=20
> At this point I am inclined to think that the kernel multicast routin=
g
> might have an issue? I might have missing a network configuration
> setting but at this point I am baffled.  I checked the kernel bugbase
> with the multicast tagging and couldn't find a filled bug regarding
> this matter. The only remaining options for me are to fill a bug and
> trace the kernel code (ipmr.c) to understand what going on. Can
> someone shade light on this? Is this an expected behavior or an issue=
?
>=20
> Thanks
> GB=20
>     =20


