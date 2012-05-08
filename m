From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: update the usage of CHECKSUM_UNNECESSARY
Date: Tue, 8 May 2012 20:48:32 +0300
Message-ID: <20120508174831.GA27406@redhat.com>
References: <20120319211241.11291.53271.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devel@open-fcoe.org,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com
To: Yi Zou <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab2EHRsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 13:48:46 -0400
Content-Disposition: inline
In-Reply-To: <20120319211241.11291.53271.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 19, 2012 at 02:12:41PM -0700, Yi Zou wrote:
> As suggested by Ben, this adds the clarification on the usage of
> CHECKSUM_UNNECESSARY on the outgoing patch. Also add the usage
> description of NETIF_F_FCOE_CRC and CHECKSUM_UNNECESSARY
> for the kernel FCoE protocol driver.
> 
> This is a follow-up to the following:
> http://patchwork.ozlabs.org/patch/147315/
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: www.Open-FCoE.org <devel@open-fcoe.org>
> ---
> 
>  include/linux/skbuff.h |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 8dc8257..a2b9953 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -94,6 +94,13 @@
>   *			  about CHECKSUM_UNNECESSARY. 8)
>   *	NETIF_F_IPV6_CSUM about as dumb as the last one but does IPv6 instead.
>   *
> + *	UNNECESSARY: device will do per protocol specific csum. Protocol drivers
> + *	that do not want net to perform the checksum calculation should use
> + *	this flag in their outgoing skbs.
> + *	NETIF_F_FCOE_CRC  this indicates the device can do FCoE FC CRC
> + *			  offload. Correspondingly, the FCoE protocol driver
> + *			  stack should use CHECKSUM_UNNECESSARY.
> + *
>   *	Any questions? No questions, good. 		--ANK
>   */
>  

So just to make sure I understand, you never get
UNNECESSARY packets on tx unless you declared NETIF_F_FCOE_CRC?

Maybe the comment says this somehow but could not figure it out.



> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
