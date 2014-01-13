From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Mon, 13 Jan 2014 20:50:13 +0000
Message-ID: <1389646213.2025.159.camel@bwh-desktop.uk.level5networks.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <20140113.115913.1269834557058575064.davem@davemloft.net>
	 <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <therbert@google.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50882 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbaAMUuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 15:50:17 -0500
In-Reply-To: <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 12:17 -0800, Eric Dumazet wrote:
> On Mon, 2014-01-13 at 11:59 -0800, David Miller wrote:
> 
> > It also doesn't jive well with Eric's recent patch to adjust the GRO
> > overflow strategy (600adc18eba823f9fd8ed5fec8b04f11dddf3884 ("net:
> > gro: change GRO overflow strategy"))
> > 
> > :-)
> > 
> > I sort of like Tom's idea to optimistically compare the hash, if we
> > do in fact have one already.
> > 
> > Eric would the change be OK if Tom did it that way?
> > --
> 
> Yes this is what I suggested, but it seems Tom had something different
> in mind.
> 
> I would rather not call flow dissector from GRO, especially considering
> nobody but Google uses RPS/RFS (otherwise CVE-2013-4348 would have been
> discovered much sooner)

According to the original report of that vulnerability:

> skb_flow_dissect() were used by several places:                         
> - packet scheduler that want classify flows                             
> - skb_get_rxhash() that will be used by RPS, vxlan, multiqueue          
> tap,macvtap packet fanout                                               
> - skb_probe_transport_header() which was used for probing transport     
> header for DODGY packets                                                
> - __skb_get_poff() which will be used by socket filter             

So flow dissector is already part of the attack surface for both local
and remote users in common configurations.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
