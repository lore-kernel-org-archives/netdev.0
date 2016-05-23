From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: Missing INET6_PROTO_FINAL in l2tp_ip6_protocol?
Date: Mon, 23 May 2016 14:25:21 +0300
Message-ID: <20160523142521.6d0d018c@pixies>
References: <20160521155003.1410579f@halley>
	<9bd1a821-17ea-778a-b0c7-4e9e35f9fcc1@stressinduktion.org>
	<20160521230252.27931eee@halley>
	<da054ee9-66bf-5038-b78b-18ce1c362014@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36667 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbcEWLZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 07:25:31 -0400
Received: by mail-wm0-f49.google.com with SMTP id n129so73094816wmn.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 04:25:30 -0700 (PDT)
In-Reply-To: <da054ee9-66bf-5038-b78b-18ce1c362014@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 23 May 2016 13:05:50 +0200, hannes@stressinduktion.org wrote:
> > However, one more thing WRT to INET6_PROTO_FINAL not being set - we're
> > also missing the multicast filtering of 'ip6_input_finish':
> > 
> > 			if (ipv6_addr_is_multicast(&hdr->daddr) &&
> > 			    !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr,
> > 			    &hdr->saddr) &&
> > 			    !ipv6_is_mld(skb, nexthdr, skb_network_header_len(skb)))
> > 				goto discard;
> > 
> > I assume no reason to allow multicast daddr which aren't in the mc_list
> > (or saddr excluded) to pass up into 'l2tp_ip6_recv'?
> > 
> 
> Good point, seems we would benefit of the addition of the PROTO_FINAL
> flag. Could you test and send a patch?

Will do.

Regards,
Shmulik
