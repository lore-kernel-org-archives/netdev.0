From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 10/16] batman-adv: use CRC32C instead of CRC16 in TT code
Date: Wed, 9 Oct 2013 15:11:08 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7384@saturn3.aculab.com>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com> <1381322418-1349-11-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <b.a.t.m.a.n@lists.open-mesh.org>,
	"Antonio Quartulli" <ordex@autistici.org>,
	"Marek Lindner" <lindner_marek@yahoo.de>
To: "Antonio Quartulli" <antonio@meshcoding.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48273 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753792Ab3JIONC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 10:13:02 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12891-04 for <netdev@vger.kernel.org>;
 Wed,  9 Oct 2013 15:12:59 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1381322418-1349-11-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> CRC32C has to be preferred to CRC16 because of its possible
> HW native support and because of the reduced collision
> probability. With this change the Translation Table
> component now uses CRC32C to compute the local and global
> table checksum.
...
> -/* Calculates the checksum of the local table of a given orig_node */
> -static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
> +/**
> + * batadv_tt_global_crc - calculates the checksum of the local table belonging
> + *  to the given orig_node
> + * @bat_priv: the bat priv with all the soft interface information
> + */
> +static uint32_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
>  				     struct batadv_orig_node *orig_node)
...
>  	for (i = 0; i < hash->size; i++) {
>  		head = &hash->table[i];
> @@ -1435,27 +1437,24 @@ static uint16_t batadv_tt_global_crc(struct batadv_priv *bat_priv,
>  							     orig_node))
>  				continue;
> 
...
> +			crc ^= crc32c(0, tt_common->addr, ETH_ALEN);
>  		}

Are you really generating CRC32 of a pile of ethernet MAC addresses
and the XORing the CRC together?
That gives the same answer as XORing together the MAC addresses and
then doing a CRC of the final value.
So it gives you almost no protection against corruption at all.

...
> -/* Calculates the checksum of the local table */
> -static uint16_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
> +/**
> + * batadv_tt_local_crc - calculates the checksum of the local table
> + * @bat_priv: the bat priv with all the soft interface information
> + */
> +static uint32_t batadv_tt_local_crc(struct batadv_priv *bat_priv)
>  {
...

This looks like a clone of the previous routine.
Surely you can avoid the code duplication.

	David
