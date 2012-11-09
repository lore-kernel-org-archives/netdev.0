From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gro vs vlan in myri10ge
Date: Thu, 08 Nov 2012 18:41:10 -0800
Message-ID: <1352428870.19779.496.camel@edumazet-glaptop>
References: <509C6858.6010105@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51698 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab2KIClM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 21:41:12 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so2439488pad.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 18:41:12 -0800 (PST)
In-Reply-To: <509C6858.6010105@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 21:20 -0500, Andrew Gallatin wrote:
> Hi,
> 
> I've wanted to convert myri10ge from LRO to GRO for quite a while.
> The problem I'm facing is that the NIC cannot perform hardware vlan
> tag offload, so GRO performance is far below LRO performance when
> receiving vlan tagged TCP traffic.
> 
> If a vlan tagged frame is passed to lro_receive_frags(), inet_lro will
> look at the encapsulated IPv4 frame and TCP aggregation will succeed.
> However, it appears that GRO will not do this.  When I patch the
> driver to use GRO, and configure a vlan interface, I see high CPU
> utilization and poor bandwidth when I'm receiving a netperf TCP stream
> on the vlan interface.  If I use LRO in an unpatched driver, then I
> see good receive performance in the same scenario.
> 
> What is the best way to "fix" this?
> 
> Unless I'm just using GRO wrong, it seems that the simplest thing for
> me to do is to claim NETIF_F_HW_VLAN_RX, but pop the tags in the
> driver so as to allow myri10ge to pass up a non-encapsulated frame the
> same way that (nearly?) every other 10GbE NIC does.  I've got a quick
> and dirty patch that confirms doing the vtag pop in the driver gives
> me roughly the same performance with GRO as I used to have with LRO.
> 
> Is this (popping vlan tags in the driver) acceptable, or is it
> too much of a layering violation?

Given GRO assumes NIC does hardware vlan offloading, I guess
I would chose to do that.

It seems unfortunate to add vlan decap in GRO path, already very
complex.
