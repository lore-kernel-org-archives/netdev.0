From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 9 Aug 2016 10:18:41 +0800
Message-ID: <57A93D81.4030808@huawei.com>
References: <20160808211530.GH22974@cork> <20160808212112.GI22974@cork>
 <20160808214812.GJ22974@cork>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Andy Gospodarek <andy@greyhouse.net>, <netdev@vger.kernel.org>
To: =?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:15911 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbcHICZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 22:25:30 -0400
In-Reply-To: <20160808214812.GJ22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/8/9 5:48, Jörn Engel wrote:
> Up until 00503b6f702e (part of 3.14-rc1), the bonding driver could be
> used to enslave tun-interfaces.  00503b6f702e broke that behaviour,
> afaics as an unintended side-effect.
> 

Hi Jorn:

I don't understand your problem clearly, can you explain more about how the 00503b6f702e break tun-interfaces
and we will try to fix it.

and more, dev_set_mac_address will change the salver's mac address, some nic don't support to change the mac address and
could not work as bond slave, so we need to check the return value, I don't think this patch has any effective improvement.

Thanks.
Ding

> For the purpose of bond-over-tun in balance-rr mode, simply ignoring the
> error from dev_set_mac_address() is good enough.  I am not familiar
> enough with the code to judge what new problems this patch might
> introduce.
> 
> Signed-off-by: Joern Engel <joern@purestorage.com>
> ---
>  drivers/net/bonding/bond_main.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 1f276fa30ba6..bc5dba847f50 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1489,11 +1489,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  		 */
>  		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
>  		addr.sa_family = slave_dev->type;
> -		res = dev_set_mac_address(slave_dev, &addr);
> -		if (res) {
> -			netdev_dbg(bond_dev, "Error %d calling set_mac_address\n", res);
> -			goto err_restore_mtu;
> -		}
> +		dev_set_mac_address(slave_dev, &addr);
>  	}
>  
>  	/* set slave flag before open to prevent IPv6 addrconf */
> @@ -1777,7 +1773,6 @@ err_restore_mac:
>  		dev_set_mac_address(slave_dev, &addr);
>  	}
>  
> -err_restore_mtu:
>  	dev_set_mtu(slave_dev, new_slave->original_mtu);
>  
>  err_free:
> 
