From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 05/24] net: rbridge: Adapt Bridge structure
Date: Wed, 24 Sep 2014 22:56:44 +0200
Message-ID: <20140924205644.GB14754@electric-eye.fr.zoreil.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
 <1411573940-14079-6-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, william@gandi.net,
	f.cachereul@alphalink.fr, Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41170 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbaIXU4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:56:46 -0400
Content-Disposition: inline
In-Reply-To: <1411573940-14079-6-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ahmed Amamou <ahmed@gandi.net> :
[...]
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index 9c5529d..09dc18c 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
[...]
> @@ -391,4 +401,28 @@ static inline unsigned long compare_ether_header(const void *a, const void *b)
>  #endif
>  }
>  
> +#ifdef CONFIG_TRILL
> +/**
> + * is_all_rbr_address - check if it is a specific Rbridge brodcast mac address
> + * @addr1: Pointer to a six-byte array containing the Ethernet address
> + *
> + * returns true if it is a RBridge brodcast address 01:80:C2:00:00:40
> + */
> +static inline bool is_all_rbr_address(const u8 * addr1)
> +{
> +	return ether_addr_equal(addr1, eth_reserved_addr_all_rbridge);
> +}
> +
> +static inline bool is_isis_rbr_address(const u8 * addr1)
> +{
> +	return ether_addr_equal(addr1, eth_reserved_addr_isis_rbridge);
> +}
> +
> +static inline bool is_esadi_rbr_address(const u8 * addr1)
> +{
> +	return ether_addr_equal(addr1, eth_reserved_addr_esadi_rbridge);
> +}

Nit: s/addr1/addr (there's no addr2).

Neither is_isis_rbr_address nor is_esadi_rbr_address is ever used. They
could be added later.

You may consider merging the hunk above with patch #15.

-- 
Ueimor
