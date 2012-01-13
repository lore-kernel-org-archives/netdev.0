From: Simon Chen <simonchennj@gmail.com>
Subject: Re: stable bonding config
Date: Thu, 12 Jan 2012 21:52:25 -0500
Message-ID: <CANj2Ebf4f3o+zKMLvqiVGyMegdJiqUzVupkOLuKqmxuaVSTdyg@mail.gmail.com>
References: <CANj2Ebc8+Uu6gW8=Jsb42Cr2Ry88cvys-DZrkeX8Rh+uvAsRAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:41508 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab2AMCw2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 21:52:28 -0500
Received: by wibhm14 with SMTP id hm14so35444wib.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 18:52:26 -0800 (PST)
In-Reply-To: <CANj2Ebc8+Uu6gW8=Jsb42Cr2Ry88cvys-DZrkeX8Rh+uvAsRAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using the following:

Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
ixgbe 3.7.17 driver (latest from intel)

Thanks.
-Simon

On Thu, Jan 12, 2012 at 9:31 PM, Simon Chen <simonchennj@gmail.com> wro=
te:
> Hi all,
>
> Not sure if this is the right place to ask, but I got very good
> answers about this topic in the past...
>
> I am mostly using Ubuntu 10.10. Each server has dual intel 10G NICs,
> which I want to bond. I configured the switches to support 802.3ad.
> Based on this post http://ubuntuforums.org/showthread.php?t=3D1595177=
, I
> configure the server as:
>
> /home/simon# cat /etc/modprobe.d/aliases.conf
> alias bond0 bonding
> options bonding mode=3D4 miimon=3D100 lacp_rate=3D1 downdelay=3D200
> updelay=3D200 ad_select=3D1 xmit_hash_policy=3D1
>
> /home/simon# cat /etc/network/interfaces
> ...
> auto bond0
> iface bond0 inet manual
> =A0 =A0 =A0 =A0bond-slaves none
> =A0 =A0 =A0 =A0bond-mode 4
> =A0 =A0 =A0 =A0bond-miimon 100
> =A0 =A0 =A0 =A0up /sbin/ifenslave bond0 eth2 eth3
> =A0 =A0 =A0 =A0down /sbin/ifenslave bond0 eth2 eth3
>
> auto eth2
> iface eth2 inet manual
> bond-master bond0
> bond-primary eth2 eth3
>
> auto eth3
> iface eth3 inet manual
> bond-master bond0
> bond-primary eth2 eth3
>
> auto bond0.200
> iface bond0.200 inet static
> =A0address ...
> =A0vlan_raw_device bond0
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
>
> However, after a reboot the bonding doesn't work immediately. In part=
icular:
>
> /home/simon# cat /proc/net/bonding/bond0
> ...
> 802.3ad info
> LACP rate: fast
> Aggregator selection policy (ad_select): bandwidth
> Active Aggregator Info:
> =A0 =A0 =A0 =A0Aggregator ID: 3
> =A0 =A0 =A0 =A0Number of ports: 2
> =A0 =A0 =A0 =A0Actor Key: 33
> =A0 =A0 =A0 =A0Partner Key: 19
> =A0 =A0 =A0 =A0Partner Mac Address: 00:00:00:00:00:00 <------bonding =
not working
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> The only magic to get it work that I know of, is to perform "rmmod
> ixgbe" "modprobe ixgbe" and then "ifconfig eth2 0.0.0.0 up" "ifconfig
> eth3 0.0.0.0 up" "ifdown bond0" "ifup bond0".
>
> Is there a hassle-free bonding configuration that I can use? Or some
> trick that I am not aware of?
>
> Thanks.
> -Simon
