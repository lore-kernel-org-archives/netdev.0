From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 30/40] ixgbe: add support for nfc addition and
 removal of filters
Date: Tue, 07 Jun 2011 22:24:39 +0100
Message-ID: <1307481879.2908.25.camel@bwh-desktop>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307449995-9458-31-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23207 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757514Ab1FGVYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 17:24:43 -0400
In-Reply-To: <1307449995-9458-31-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-07 at 05:33 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change is meant to allow for nfc to insert and remove filters in order
> to test the ethtool interface which includes it's own rules manager.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ixgbe/ixgbe_ethtool.c |  245 +++++++++++++++++++++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_main.c    |   45 +++++++
>  2 files changed, 290 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
> index 2c70363..f37c9b8 100644
> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
[...]
> +	/* Copy input into formatted structures */
> +	input->filter.formatted.src_ip[0] = fsp->h_u.tcp_ip4_spec.ip4src;
> +	mask.formatted.src_ip[0] = fsp->m_u.tcp_ip4_spec.ip4src;
> +	input->filter.formatted.dst_ip[0] = fsp->h_u.tcp_ip4_spec.ip4dst;
> +	mask.formatted.dst_ip[0] = fsp->m_u.tcp_ip4_spec.ip4dst;
> +	input->filter.formatted.src_port = fsp->h_u.tcp_ip4_spec.psrc;
> +	mask.formatted.src_port = fsp->m_u.tcp_ip4_spec.psrc;
> +	input->filter.formatted.dst_port = fsp->h_u.tcp_ip4_spec.pdst;
> +	mask.formatted.dst_port = fsp->m_u.tcp_ip4_spec.pdst;
> +
> +	if (fsp->flow_type & FLOW_EXT) {
> +		input->filter.formatted.vm_pool =
> +				(unsigned char)ntohl(fsp->h_ext.data[1]);
> +		mask.formatted.vm_pool =
> +				(unsigned char)ntohl(fsp->m_ext.data[1]);
> +		input->filter.formatted.vlan_id = fsp->h_ext.vlan_tci;
> +		mask.formatted.vlan_id = fsp->m_ext.vlan_tci;
> +		input->filter.formatted.flex_bytes =
> +						fsp->h_ext.vlan_etype;
> +		mask.formatted.flex_bytes = fsp->m_ext.vlan_etype;
> +	}
[...]

Sure you don't need any byte-swapping for the IP, port, and VLAN tag?

Also is the 'vlan_id' field used to match the whole VLAN/priority tag or
only the VID?  If it only matches the VID then you need to check that
the priority and CF bits are not set in the given mask.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

