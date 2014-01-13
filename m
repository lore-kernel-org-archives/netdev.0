From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Mon, 13 Jan 2014 13:37:41 -0800
Message-ID: <1389649061.31367.236.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <20140113.115913.1269834557058575064.davem@davemloft.net>
	 <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389646213.2025.159.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f173.google.com ([209.85.161.173]:34493 "EHLO
	mail-gg0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbaAMVho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 16:37:44 -0500
Received: by mail-gg0-f173.google.com with SMTP id n5so720688ggj.4
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 13:37:43 -0800 (PST)
In-Reply-To: <1389646213.2025.159.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 20:50 +0000, Ben Hutchings wrote:

> According to the original report of that vulnerability:
> 
> > skb_flow_dissect() were used by several places:                         
> > - packet scheduler that want classify flows                             
> > - skb_get_rxhash() that will be used by RPS, vxlan, multiqueue          
> > tap,macvtap packet fanout                                               
> > - skb_probe_transport_header() which was used for probing transport     
> > header for DODGY packets                                                
> > - __skb_get_poff() which will be used by socket filter             
> 
> So flow dissector is already part of the attack surface for both local
> and remote users in common configurations.

Take a debian or Android distro, and this bug is not hit on 'common
configurations'. Send them a 'packet of death', they will not hang,
unless some admin set up RPS/RFS on the incoming device.

Anyway, I see no point pushing this schem (flow dissect all incoming
packets). A router has no gain going to L4 header, but still might
need GRO.
