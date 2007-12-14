From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Fri, 14 Dec 2007 21:59:30 +0100
Message-ID: <4762EEB2.1080608@gmail.com>
References: <4762646B.30207@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:19239 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524AbXLNU5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 15:57:49 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1034223nfb.21
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 12:57:48 -0800 (PST)
In-Reply-To: <4762646B.30207@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 12/14/2007 12:09 PM:
...

> +	/*
> +	 * Instead of returning hash % ht->cfg.size (implying a divide)
> +	 * we return the high 32 bits of the (hash * ht->cfg.size) that will
> +	 * give results between [0 and cfg.size-1] and same hash distribution,
> +	 * but using a multiply, less expensive than a divide
> +	 */
> +	return ((u64)hash * ht->cfg.size) >> 32;

Are we sure of the same hash distribution? Probably I miss something,
but: if this 'hash' is well distributed on 32 bits, and ht->cfg.size
is smaller than 32 bits, e.g. 256 (8 bits), then this multiplication
moves to the higher 32 of u64 only max. 8 bits of the most significant
byte, and the other three bytes are never used, while division is
always affected by all four bytes...

Regards,
Jarek P.
