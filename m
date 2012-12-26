From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] batman-adv: fix random jitter calculation
Date: Wed, 26 Dec 2012 14:13:50 -0800 (PST)
Message-ID: <20121226.141350.999199516661256197.davem@davemloft.net>
References: <1356525130-2688-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lindner_marek@yahoo.de, siwu@hrz.tu-chemnitz.de,
	ordex@autistici.org, b.a.t.m.a.n@lists.open-mesh.org
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab2LZWOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 17:14:14 -0500
In-Reply-To: <1356525130-2688-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Wed, 26 Dec 2012 21:32:10 +0900

> batadv_iv_ogm_emit_send_time() attempts to calculates a random integer
> in the range of 'orig_interval +- BATADV_JITTER' by the below lines.
> 
>         msecs = atomic_read(&bat_priv->orig_interval) - BATADV_JITTER;
>         msecs += (random32() % 2 * BATADV_JITTER);
> 
> But it actually gets 'orig_interval' or 'orig_interval - BATADV_JITTER'
> because '%' and '*' have same precedence and associativity is
> left-to-right.
> 
> This adds the parentheses at the appropriate position so that it matches
> original intension.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Acked-by: Antonio Quartulli <ordex@autistici.org>

Applied, thanks.
