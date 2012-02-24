From: Bhavesh Davda <bhavesh@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 08/12] vmxnet3: check given MAC address,	if
 invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 08:31:44 -0800
Message-ID: <085E4D48-DF23-4C85-84DF-8321CA236304@vmware.com>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
 <1330099282-4588-9-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330099282-4588-9-git-send-email-danny.kukawka@bisect.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lgtm.

Reviewed-by: Bhavesh Davda <bhavesh@vmware.com>

- Bhavesh

(From my iPhone)


On Feb 24, 2012, at 8:01 AM, "Danny Kukawka" <danny.kukawka@bisect.de> wrote:

> Check if given address is valid in .ndo_set_mac_address/
> vmxnet3_set_mac_addr(), if invalid return -EADDRNOTAVAIL as
> eth_mac_addr() already does if is_valid_ether_addr() fails.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
> drivers/net/vmxnet3/vmxnet3_drv.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index e1562e8..bd2a7cd 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -2331,6 +2331,9 @@ vmxnet3_set_mac_addr(struct net_device *netdev, void *p)
>    struct sockaddr *addr = p;
>    struct vmxnet3_adapter *adapter = netdev_priv(netdev);
> 
> +    if (!is_valid_ether_addr(addr->sa_data))
> +        return -EADDRNOTAVAIL;
> +
>    memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
>    vmxnet3_write_mac_addr(adapter, addr->sa_data);
> 
> -- 
> 1.7.8.3
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
