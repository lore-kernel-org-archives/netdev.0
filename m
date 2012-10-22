From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Mon, 22 Oct 2012 08:48:09 +0200
Message-ID: <1350888489.8609.322.camel@edumazet-glaptop>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	 <20121013163639.87abca00.bircoph@gmail.com>
	 <1350135860.21172.14606.camel@edumazet-glaptop>
	 <20121014031119.a60263d6.bircoph@gmail.com>
	 <20121021032543.09d1844f.bircoph@gmail.com>
	 <1350823941.13333.2167.camel@edumazet-glaptop>
	 <20121022073636.98462bc6.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:57099 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932284Ab2JVGsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 02:48:16 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so694983eaa.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 23:48:14 -0700 (PDT)
In-Reply-To: <20121022073636.98462bc6.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-22 at 07:36 +0400, Andrew Savchenko wrote:

> 
> I'll try 3.7 branch in a week or so. New kernel will require some
> reconfiguration.
> 
> > What NIC are you using ?
> 
> This host has four NICs:
> 2x Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (10ec:8139)
> 2x D-Link System Inc DGE-528T Gigabit Ethernet Adapter (1462:223c)
> 
> One D-Link card is operating on 1Gbit/FD with mtu 7000, other cards
> are used as 100Mbit/FD mtu 1500.
> 
> 2 D-Link and 1 Realtek card are forming a bridge and remaining Realtek
> card is used for an uplink. This host serves as a NAT between
> the bridge and the uplink (both MASQUERADE and DNAT are used). Also it
> has several ipsec tunnels for multiple hosts (mostly AH), l2tp tunnel
> (independent from ipsec) and serves as a multicast router using
> mrouted. Rather sophisticated ebtables, iptables and ipset setup is
> used.
> 
> Best regards,
> Andrew Savchenko

Some driver or protocol stack is messing with skb->truesize, as
your /proc/net/udp file contains anomalies :

$ cat /proc/net/udp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops
...
  323: 074A070A:007B 00000000:0000 07 FFFDF700:00000000 00:00000000 00000000   123        0 254469 2 ffff88003d581880 0
...
  323: 00FCA8C0:007B 00000000:0000 07 FFFFF900:00000000 00:00000000 00000000     0        0 5187 2 ffff880039993880 0

Its clearly not possible to get tx_queue = 0xFFFDF700 or 0xFFFFF900

So what drivers handle following IP addresses : 192.168.252.0 , 10.7.74.7  ?

lspci -v
lsmod

 
