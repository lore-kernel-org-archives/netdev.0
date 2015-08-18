From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 5/9] geneve: Add support to collect tunnel
 metadata.
Date: Tue, 18 Aug 2015 14:12:32 -0700 (PDT)
Message-ID: <20150818.141232.155283851688115226.davem@davemloft.net>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com>
	<1439845905-31666-6-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbHRVMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 17:12:33 -0400
In-Reply-To: <1439845905-31666-6-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 17 Aug 2015 14:11:41 -0700

> +	if (tun_dst)
> +		skb_dst_set(skb, (struct dst_entry *)tun_dst);
> +

Please don't cast things like this, it is completely unnecessary:

	skb_dst_set(skb, &tun_dst->dst);
