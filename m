From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] batman-adv: don't rely on positions in struct
 for hashing
Date: Tue, 13 Nov 2012 14:24:01 -0500 (EST)
Message-ID: <20121113.142401.1673481049958731174.davem@davemloft.net>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
	<1352798139-19458-2-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	simon.wunderlich@s2003.tu-chemnitz.de, siwu@hrz.tu-chemnitz.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815Ab2KMTYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:24:03 -0500
In-Reply-To: <1352798139-19458-2-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Tue, 13 Nov 2012 10:15:29 +0100

> @@ -37,18 +37,26 @@ static void batadv_bla_periodic_work(struct work_struct *work);
>  static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
>  				     struct batadv_backbone_gw *backbone_gw);
>  
> +static inline void hash_bytes(uint32_t *hash, void *data, uint32_t size)
> +{
> +	const unsigned char *key = data;
> +	int i;
> +
> +	for (i = 0; i < size; i++) {
> +		*hash += key[i];
> +		*hash += (*hash << 10);
> +		*hash ^= (*hash >> 6);
> +	}
> +}
> +

Remove the inline tag.

Return the uint32_t resulting hash value rather than passing it by
reference.
