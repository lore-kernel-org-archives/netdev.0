From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/4] staging: rtl8712: Make error handling check for
 failure
Date: Sun, 7 Feb 2016 19:48:39 -0800
Message-ID: <20160208034839.GB22850@kroah.com>
References: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
 <1448367582-8041-4-git-send-email-mukadr@gmail.com>
 <20151125114410.GA7946@sudip-pc>
 <5655CC03.8060402@gmail.com>
 <5655CDEE.8040603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Mauro Dreissig <mukadr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56972 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbcBHDsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 22:48:39 -0500
Content-Disposition: inline
In-Reply-To: <5655CDEE.8040603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2015 at 01:04:14PM -0200, Mauro Dreissig wrote:
> On 25-11-2015 12:56, Mauro Dreissig wrote:
> > On 25-11-2015 09:44, Sudip Mukherjee wrote:
> >> On Tue, Nov 24, 2015 at 10:19:41AM -0200, Mauro Dreissig wrote:
> >>> Some error handling paths are checking for success
> >>> instead of error on rtl871x_ioctl_rtl.c.
> >>>
> >>> Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
> >>> ---
> >>>  drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 239 ++++++++++++++--------------
> >>>  1 file changed, 121 insertions(+), 118 deletions(-)
> >>>
> >> <snip>  
> >>> @@ -147,13 +147,13 @@ uint oid_rt_get_rx_icv_err_hdl(struct oid_par_priv *poid_par_priv)
> >>>  
> >>>  	if (poid_par_priv->type_of_oid != QUERY_OID)
> >>>  		return RNDIS_STATUS_NOT_ACCEPTED;
> >>> -	if (poid_par_priv->information_buf_len >= sizeof(u32)) {
> >>> -		*(uint *)poid_par_priv->information_buf =
> >>> -					 adapter->recvpriv.rx_icv_err;
> >>> -		*poid_par_priv->bytes_rw = poid_par_priv->information_buf_len;
> >>> -	} else {
> >>> +
> >>> +	if (poid_par_priv->information_buf_len < sizeof(u32)) 
> >>
> >> trailing whitespace here.
> >> Please always test your patch with checkpatch.
> >>
> >> regards
> >> sudip
> >>
> > This blank line is intentional, there is no trailing whitespace.
> > 
> > thanks,
> > Mauro
> > 
> My mistake, seems like I fixed it in the other patch in the series.

Which isn't ok, please fix up the series and resend.

thanks,

greg k-h
