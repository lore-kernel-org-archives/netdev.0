From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: fix DO and PROBE pmtu mode regarding local fragmentation with UFO/CORK
Date: Sun, 27 Oct 2013 15:37:11 +0100
Message-ID: <20131027143710.GA7442@order.stressinduktion.org>
References: <20131025194003.GG15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60137 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab3J0OhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 10:37:12 -0400
Content-Disposition: inline
In-Reply-To: <20131025194003.GG15744@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 25, 2013 at 09:40:03PM +0200, Hannes Frederic Sowa wrote:
>  	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
>  	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
> +	maxmsgsize = (inet->pmtudisc >= IP_PMTUDISC_DO) ?
> +		     maxfraglen : 0xFFFF;

Oops, sorry. I just realized that the check is too strict. The 64
bit boundary restricton is solely used if we are actually generating
fragments. So I should have used mtu directly instead of maxfraglen.

This should only matter in case of some unusual MTUs but I will send a
corrected patch as soon as I am at home.

Greetings,

  Hannes
