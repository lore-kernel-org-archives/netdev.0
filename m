From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 1/3] ethtool: Clarify use of size field for
 ETHTOOL_GRXFHINDIR
Date: Thu, 15 Dec 2011 17:14:03 -0800
Message-ID: <20111216011403.GA8197@mcarlson.broadcom.com>
References: <1323993076.2773.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4712 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753699Ab1LPBNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 20:13:39 -0500
In-Reply-To: <1323993076.2773.23.camel@bwh-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2011 at 03:51:16PM -0800, Ben Hutchings wrote:
> In order to find out the device's RX flow hash table size, ethtool
> initially uses ETHTOOL_GRXFHINDIR with a buffer size of zero.  This
> must be supported, but it is not necessary to support any other user
> buffer size less than the device table size.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  include/linux/ethtool.h |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 20db5b27..0ec2fd4 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -543,8 +543,9 @@ struct compat_ethtool_rxnfc {
>  /**
>   * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
>   * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
> - * @size: On entry, the array size of the user buffer.  On return from
> - *	%ETHTOOL_GRXFHINDIR, the array size of the hardware indirection table.
> + * @size: On entry, the array size of the user buffer, which may be zero
> + *	for %ETHTOOL_GRXFHINDIR.  On return from %ETHTOOL_GRXFHINDIR, the
> + *	array size of the hardware indirection table.

Can we roll in the documentation request you gave me earlier?  Something
to the effect of:

"A zero size with %ETHTOOL_SRXFHINDIR means userspace relinquishes
control of the indirection table."

>   * @ring_index: RX ring/queue index for each hash value
>   */
>  struct ethtool_rxfh_indir {
> -- 
> 1.7.4.4
> 
> 
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
