From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 21:32:04 -0700
Message-ID: <1461040324.10638.159.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
	 <20160418.234137.26692086759328024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36468 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbcDSEcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 00:32:07 -0400
Received: by mail-pa0-f52.google.com with SMTP id er2so2384560pad.3
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 21:32:06 -0700 (PDT)
In-Reply-To: <20160418.234137.26692086759328024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 23:41 -0400, David Miller wrote:
>  
> +	/* Add a zero length NOP attribute so that the nla_data()
> +	 * of the IFLA_STATS64 will be 64-bit aligned.
> +	 */
> +#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
> +	attr = nla_reserve(skb, IFLA_PAD, 0);
> +	if (!attr)
> +		return -EMSGSIZE;
> +#endif

You must do this only if current skb->data alignment is not correct.

(IFLA_ALIAS for example could shift your expectations)

Also you probably want to change if_nlmsg_size() to add
 + nla_total_size(0) /* IFLA_PAD */
