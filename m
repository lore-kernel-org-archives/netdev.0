From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 11:11:34 -0800
Message-ID: <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36076 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbbKCTLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 14:11:36 -0500
Received: by pacdm15 with SMTP id dm15so2039072pac.3
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 11:11:36 -0800 (PST)
In-Reply-To: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-03 at 19:33 +0200, Denys Fedoryshchenko wrote:
> Hi
> 
> Recently i was testing shaping over single 10G cards, for speeds up to 
> 3-4Gbps, and noticed interesting effect.
> 
> Shaping scheme:
> Incoming bandwidth comes to switch port, with access vlan 100
> Outgoing bandwidth leaves switch port with access vlan 200
> Linux with Intel X710 connected to trunk port, bridge created, eth0.100 
> bridged to eth0.200
> gso/gro/tso disabled (they doesn't work nice with shapers)

Well, this seems urban legend to me.

Something that is repeatedly copied/pasted on many web pages since last
century.

Given the nature of qdisc (being protected by a spinlock), you
absolutely want to have some kind of aggregation.

I have a patch to allow a sysadmin to set a max gro segs value to
incoming packets. You could play with it. Start with 4 segments,
allow GSO/TSO on the output and watch performance coming back.
