From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH 3/4] staging: rtl8712: Make error handling check for
 failure
Date: Wed, 25 Nov 2015 17:14:10 +0530
Message-ID: <20151125114410.GA7946@sudip-pc>
References: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
 <1448367582-8041-4-git-send-email-mukadr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
To: Mauro Dreissig <mukadr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36473 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbbKYLoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 06:44:21 -0500
Received: by pacdm15 with SMTP id dm15so55414518pac.3
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 03:44:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448367582-8041-4-git-send-email-mukadr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 10:19:41AM -0200, Mauro Dreissig wrote:
> Some error handling paths are checking for success
> instead of error on rtl871x_ioctl_rtl.c.
> 
> Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
> ---
>  drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 239 ++++++++++++++--------------
>  1 file changed, 121 insertions(+), 118 deletions(-)
> 
<snip>  
> @@ -147,13 +147,13 @@ uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *poid_par_priv)
>  
>  	if (poid_par_priv->type_of_oid != QUERY_OID)
>  		return RNDIS_STATUS_NOT_ACCEPTED;
> -	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
> -		*(uint *)poid_par_priv->information_buf =
> -					 adapter->recvpriv.rx_icv_err;
> -		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
> -	} else {
> +
> +	if (poid_par_priv->information_buf_len < sizeof(u32)) 

trailing whitespace here.
Please always test your patch with checkpatch.

regards
sudip
