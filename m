From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] net: l3mdev: prefer VRF master for
 source address selection
Date: Wed, 24 Feb 2016 14:16:39 -0500 (EST)
Message-ID: <20160224.141639.1732481853660602743.davem@davemloft.net>
References: <1456165431-867-1-git-send-email-dsa@cumulusnetworks.com>
	<1456165431-867-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david@opensourcerouting.org,
	equinox@diac24.net
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756398AbcBXTQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 14:16:41 -0500
In-Reply-To: <1456165431-867-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 22 Feb 2016 10:23:51 -0800

> From: David Lamparter <equinox@diac24.net>
> 
> When selecting an address in context of a VRF, the vrf master should be
> preferred for address selection.  If it isn't, the user has a hard time
> getting the system to select to their preference - the code will pick
> the address off the first in-VRF interface it can find, which on a
> router could well be a non-routable address.
> 
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> [dsa: Fixed comment style ]
> ---
> v2
> - Fixed comment per Dave's response
> 
>  net/ipv4/devinet.c | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 614904c29cbd..01119fbf3b30 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1217,6 +1217,24 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
>  no_in_dev:
>  	master_idx = l3mdev_master_ifindex_rcu(dev);
>  
> +	/* For VRFs, the VRF device takes the place of the loopback device,
> +	 * with addresses on it being preferred.  Note in such cases the
> +	 * loopback device will be among the devices that fail the master_idx
> +	 * equality check in the loop below.
> +	 */
> +	if (master_idx &&
> +	    (dev = dev_get_by_index_rcu(net, master_idx)) &&
> +	    (in_dev = __in_dev_get_rcu(dev))) {
> +
> +		for_primary_ifa(in_dev) {

Please get rid of this empty line, and resubmit this series with a proper
"0/N" header posting explaining the high level purpose of this patch
series and what it is doing.

Thanks.
