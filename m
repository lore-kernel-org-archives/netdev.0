From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 4/7] TAP: Abstract type of virtual interface from tap
 implementation
Date: Wed, 18 Jan 2017 16:27:30 -0500 (EST)
Message-ID: <20170118.162730.696191131996456647.davem@davemloft.net>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
        <1484697786-50323-5-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484697786-50323-5-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Tue, 17 Jan 2017 16:03:03 -0800

> @@ -46,22 +51,52 @@ static struct cdev macvtap_cdev;
>  #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
>  		      NETIF_F_TSO6 | NETIF_F_UFO)
>  
> +static void macvtap_count_tx_dropped(struct tap_dev *tap)
> +{
> +	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
 ...
> +static void macvtap_count_rx_dropped(struct tap_dev *tap)
> +{
> +	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);
 ...
> +static void macvtap_update_features(struct tap_dev *tap,
> +				    netdev_features_t features)
> +{
> +	struct macvlan_dev *vlan = (struct macvlan_dev *)container_of(tap, struct macvtap_dev, tap);

These casts should be completely unnecessary, please remove them.
