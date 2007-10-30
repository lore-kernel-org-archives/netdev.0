From: "Bruno Clermont" <bruno.clermont@canoe.ca>
Subject: Fwd: Bug with tun0 and VLAN
Date: Mon, 29 Oct 2007 21:11:44 -0400
Message-ID: <ef1197770710291811l7057f71y5207c2689b847e7b@mail.gmail.com>
References: <ef1197770710291207g56412df0oab164dee96b01266@mail.gmail.com>
	 <47267AEB.90506@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:48645 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbXJ3BLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 21:11:47 -0400
Received: by el-out-1112.google.com with SMTP id j27so442283elf
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 18:11:46 -0700 (PDT)
In-Reply-To: <47267AEB.90506@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I previously contacted tun driver maintainer about a bug I found and
he suggested me to forward this to you.
so, look like there is a bug in the kernel when the VLAN code is
dealing with an interface like the tun interface.

see forwarded my original mail and Max reply.

thanks!

---------- Forwarded message ----------
From: Max Krasnyansky <maxk@qualcomm.com>
Date: Oct 29, 2007 8:29 PM
Subject: Re: Bug with tun0 and VLAN
To: Bruno Clermont <bruno.clermont@gmail.com>

Hi Bruno,

> Hi,
>
> I'm writing to you, because you seem to be the maintainer of the tun driver.
>
> I hit a bug lately. I was testing this scenario:
>
> [Server1][eth0]-------(Internet)----------[eth0][Server2]
>
> I want to be able to route traffic for many VLAN into a single tunnel
> instead of invoking 1 openvpn process per VLAN. so, I tried to add VLAN
> to tun interface.
>
> I create an OpenVPN tunnel between Server1 and 2, this part work. the
> tun0 is going up. I use heavily openvpn and I'm sure of me on this part.
> I made sure openvpn did not set any IP on the tunnel.
>
> So, I added the vlan to the tun interface on both server:
>
> ifconfig tun0 up
> vconfig add tun0 1
> vconfig add tun1 2
>
> on server1:
> ifconfig tun0.1 10.0.0.1 <http://10.0.0.1> netmask 255.255.255.0
> <http://255.255.255.0> up
> ifconfig tun0.1 10.0.1.1 <http://10.0.1.1> netmask 255.255.255.0
> <http://255.255.255.0> up
>
> on server2:
> ifconfig tun0.1 10.0.0.2 <http://10.0.0.2> netmask 255.255.255.0
> <http://255.255.255.0> up
> ifconfig tun0.1 10.0.1.2 <http://10.0.1.2> netmask 255.255.255.0
> <http://255.255.255.0> up
>
> Trying to ping the other end of the tun/vlan make the kernel panic on
> the host that try to ping.
> I tried on Ubuntu Feisty and Gutsy (2.6.22) and they both crash.
>
> I tried it severals times on different host and it seem that combining
> VLAN and tun interface crash the kernel.
> it's easy to reproduce.
>
> Is it a tun driver issue? VLAN code issue? some other part of the
> kernel? I don't know.
>
> your my first attempt of communication for this issue... If it's not
> supported, at least the kernel should not panic!

Actually TUN is a point to point device, it does not have Ethernet MAC
headers. In other words VLANs would never work over TUN.
I agree though that it should not crash. So it's better to report this to
netdev mailing list. Basically VLAN code should outright refuse to attach
to TUN devices.

Max
