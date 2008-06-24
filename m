From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 08/08] ipg: run-time configurable jumbo frame support
Date: Tue, 24 Jun 2008 23:57:05 +0200
Message-ID: <20080624215704.GA28507@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0806231436350.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57096 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757652AbYFXV5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 17:57:22 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806231436350.23716@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka J Enberg <penberg@cs.helsinki.fi> :
[...]
> @@ -2124,16 +2129,33 @@
>  
>  	IPG_DEBUG_MSG("_nic_change_mtu\n");
>  
> -	/* Check that the new MTU value is between 68 (14 byte header, 46
> -	 * byte payload, 4 byte FCS) and IPG_MAX_RXFRAME_SIZE, which
> -	 * corresponds to the MAXFRAMESIZE register in the IPG.
> +	/*
> +	 * Check that the new MTU value is between 68 (14 byte header, 46 byte
> +	 * payload, 4 byte FCS) and 10 KB, which is the largest supported MTU.
>  	 */
> -	if ((new_mtu < 68) || (new_mtu > sp->max_rxframe_size))
> +	if (new_mtu < 68 || new_mtu > 10240)
>  		return -EINVAL;
>  
> +	err = ipg_nic_stop(dev);
> +	if (err)
> +		return err;

I buy it but it would be nice if the error path was more tolerant: though
not immedialtely fatal, a failure during a change of mtu will be hard to
recover from.

Could you be convinced to plan some descriptor ring trick instead of
a genuine stop / start sequence.

Something along the lines of
http://userweb.kernel.org/~romieu/via-velocity/2.6.26-rc6/20080619/
for instance (or anything more elegant you can come with).

-- 
Ueimor
