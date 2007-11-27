From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][BRIDGE] Lost call to br_fdb_fini() in br_init() error
 path
Date: Tue, 27 Nov 2007 08:19:56 -0800
Message-ID: <20071127081956.0dd3df4f@freepuppy.rosehill>
References: <474C2C2E.7050001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	bridge@lists.linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60387 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756363AbXK0QU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 11:20:59 -0500
In-Reply-To: <474C2C2E.7050001@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 17:39:42 +0300
Pavel Emelyanov <xemul@openvz.org> wrote:

> In case the br_netfilter_init() (or any subsequent call) 
> fails, the br_fdb_fini() must be called to free the allocated
> in br_fdb_init() br_fdb_cache kmem cache.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/bridge/br.c b/net/bridge/br.c
> index 93867bb..a901828 100644
> --- a/net/bridge/br.c
> +++ b/net/bridge/br.c
> @@ -39,7 +39,7 @@ static int __init br_init(void)
>  
>  	err = br_fdb_init();
>  	if (err)
> -		goto err_out1;
> +		goto err_out;
>  
>  	err = br_netfilter_init();
>  	if (err)
> @@ -65,6 +65,8 @@ err_out3:
>  err_out2:
>  	br_netfilter_fini();
>  err_out1:
> +	br_fdb_fini();
> +err_out:
>  	llc_sap_put(br_stp_sap);
>  	return err;
>  }

Good catch, thanks I hope you didn't find this in live system.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
