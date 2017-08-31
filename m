From: Vernon Mauery <vernon.mauery@linux.intel.com>
Subject: Re: [PATCH net-next] net/ncsi: Define {add, kill}_vid callbacks for
 !CONFIG_NET_NCSI
Date: Thu, 31 Aug 2017 08:24:14 -0700
Message-ID: <20170831152414.GB69617@mauery>
References: <20170831033846.23538-1-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:57165 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751276AbdHaPYP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 11:24:15 -0400
Content-Disposition: inline
In-Reply-To: <20170831033846.23538-1-sam@mendozajonas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31-Aug-2017 01:38 PM, Samuel Mendoza-Jonas wrote:
> Patch "net/ncsi: Configure VLAN tag filter" defined two new callback
> functions in include/net/ncsi.h, but neglected the !CONFIG_NET_NCSI
> case. This can cause a build error if these are referenced elsewhere
> without NCSI enabled, for example in ftgmac100:
> 
> >>> ERROR: "ncsi_vlan_rx_kill_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!
> >>> ERROR: "ncsi_vlan_rx_add_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!
> 
> Add definitions for !CONFIG_NET_NCSI to bring it into line with the rest
> of ncsi.h
> 
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
> ---
>  include/net/ncsi.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/include/net/ncsi.h b/include/net/ncsi.h
> index 1f96af46df49..2b13b6b91a4d 100644
> --- a/include/net/ncsi.h
> +++ b/include/net/ncsi.h
> @@ -36,6 +36,14 @@ int ncsi_start_dev(struct ncsi_dev *nd);
>  void ncsi_stop_dev(struct ncsi_dev *nd);
>  void ncsi_unregister_dev(struct ncsi_dev *nd);
>  #else /* !CONFIG_NET_NCSI */
> +int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
> +{
> +	return -ENOTTY;
> +}
> +int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
> +{
> +	return -ENOTTY;
> +}

These should be static functions because they are defined in the header 
file or you will get multiple symbol definitions.

--Vernon

>  static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
>  					void (*notifier)(struct ncsi_dev *nd))
>  {
> -- 
> 2.14.1
> 
