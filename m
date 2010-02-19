From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: [RFC 4/4] bond: add new multiqueue hash policy
Date: Fri, 19 Feb 2010 20:54:17 +0300
Message-ID: <76601266602057@webmail50.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward14.mail.yandex.net ([95.108.130.92]:57551 "EHLO
	forward14.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab0BSRyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 12:54:43 -0500
Received: from webmail50.yandex.ru (webmail50.yandex.ru [77.88.47.198])
	by forward14.mail.yandex.net (Yandex) with ESMTP id 77E9426806AA
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 20:54:24 +0300 (MSK)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by webmail50.yandex.ru (Yandex) with ESMTP id 6032DFB0640
	for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 20:54:18 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

> This hash policy just uses existing transmit hash used for
> mulitiqueue.

> Signed-off-by: Stephen Hemminger

> +/*
> + * Hash for the output device based on multiqueue transmit hash policy
> + */
> +static u16 bond_xmit_hash_policy_mq(const struct sk_buff *skb)
> +{
> +	return skb_tx_hash(skb->dev, skb);
> +}

I think that it would be better to use something like this here:

return skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;

Bonding is currently non-multiqueue aware and skb_tx_hash() will return zero
everytime.

-- 
wbr, Oleg.
