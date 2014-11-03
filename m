From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/7] gue: Add infrastructure for flags and
 options
Date: Mon, 03 Nov 2014 12:18:56 -0500 (EST)
Message-ID: <20141103.121856.1307429117331581815.davem@davemloft.net>
References: <1414882683-25484-1-git-send-email-therbert@google.com>
	<1414882683-25484-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbaKCRS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:18:59 -0500
In-Reply-To: <1414882683-25484-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sat,  1 Nov 2014 15:57:59 -0700

> @@ -20,7 +20,16 @@ static size_t fou_encap_hlen(struct ip_tunnel_encap *e)
>  
>  static size_t gue_encap_hlen(struct ip_tunnel_encap *e)
>  {
> -	return sizeof(struct udphdr) + sizeof(struct guehdr);
> +	size_t len;
> +	bool need_priv = false;
> +
> +	len = sizeof(struct udphdr) + sizeof(struct guehdr);
> +
> +	/* Add in lengths flags */
> +
> +	len += need_priv ? GUE_LEN_PRIV : 0;

Add this need_priv logic in patch #6, not here.
