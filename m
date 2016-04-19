From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 11:47:47 -0700
Message-ID: <1461091667.10638.229.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160418.234137.26692086759328024.davem@davemloft.net>
	 <1461040324.10638.159.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160419.010316.1863885429013017239.davem@davemloft.net>
	 <20160419.143134.2014460805657420897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33448 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932872AbcDSSrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:47:52 -0400
Received: by mail-pa0-f46.google.com with SMTP id zm5so9223141pac.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 11:47:52 -0700 (PDT)
In-Reply-To: <20160419.143134.2014460805657420897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 14:31 -0400, David Miller wrote:

> +#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
> +	/* IF necessary, add a zero length NOP attribute so that the
> +	 * nla_data() of the IFLA_STATS64 will be 64-bit aligned.
> +	 *
> +	 * The nlattr header is 4 bytes in size, that's why we test
> +	 * if the skb->data _is_ aligned.  This NOP attribute, plus
> +	 * nlattr header for IFLA_STATS64, will make nla_data() 8-byte
> +	 * aligned.
> +	 */
> +	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
> +		attr = nla_reserve(skb, IFLA_PAD, 0);
> +		if (!attr)
> +			return -EMSGSIZE;
> +	}
> +#endif

Since we want to use this in other places, we could define a helper.

nla_align_64bit(skb, attribute)  or something.
