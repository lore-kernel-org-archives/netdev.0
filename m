From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH ethtool] rxclass: Show full 64 bits of user-data in rxclass_print_nfc_spec_ext()
Date: Tue, 22 Jan 2013 13:07:27 -0800
Message-ID: <50FEFF8F.40304@intel.com>
References: <1358886835.2892.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39880 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136Ab3AVVH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 16:07:28 -0500
In-Reply-To: <1358886835.2892.14.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2013 12:33 PM, Ben Hutchings wrote:
> Previously only the lower 32 bits would be shown.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> I just noticed this bug when applying Yan Burman's patch.  Untested
> since sfc doesn't support this field.
> 
> Ben.
> 
>  rxclass.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/rxclass.c b/rxclass.c
> index 1564b62..cd686a3 100644
> --- a/rxclass.c
> +++ b/rxclass.c
> @@ -49,7 +49,7 @@ static void rxclass_print_nfc_spec_ext(struct ethtool_rx_flow_spec *fsp)
>  		tci = ntohs(fsp->h_ext.vlan_tci);
>  		tcim = ntohs(~fsp->m_ext.vlan_tci);
>  		data = (u64)ntohl(fsp->h_ext.data[0]) << 32;
> -		data = (u64)ntohl(fsp->h_ext.data[1]);
> +		data |= (u64)ntohl(fsp->h_ext.data[1]);
>  		datam = (u64)ntohl(~fsp->m_ext.data[0]) << 32;
>  		datam |= (u64)ntohl(~fsp->m_ext.data[1]);
>  
> 

This looks fine to me.  We didn't use data[0] in ixgbe so we never
noticed this either.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
