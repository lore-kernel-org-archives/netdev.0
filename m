From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] macvlan: don't update the uc and vlan
 list for L2 forwarding offload
Date: Thu, 05 Jun 2014 11:09:08 -0400
Message-ID: <53908814.8080303@gmail.com>
References: <1401969663-4464-1-git-send-email-dingtianhong@huawei.com> <1401969663-4464-2-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>, kaber@trash.net,
	davem@davemloft.net, edumazet@google.com, vyasevic@redhat.com,
	makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:41358 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbaFEPJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 11:09:12 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so1804195qgf.35
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 08:09:11 -0700 (PDT)
In-Reply-To: <1401969663-4464-2-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2014 08:01 AM, Ding Tianhong wrote:
> If lowerdev supports L2 forwarding offload, no need to set mac address
> to uc list and vlan list, so also don't do that when the macvlan mac address
> changes.

Same issue as in v1.  Please explain how this actually works, since the
new address never makes it to the hw.

-vlad
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/macvlan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 453d55a..c3a54a6 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -515,7 +515,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>  	struct net_device *lowerdev = vlan->lowerdev;
>  	int err;
>  
> -	if (!(dev->flags & IFF_UP)) {
> +	if (!(dev->flags & IFF_UP) || vlan->fwd_priv) {
>  		/* Just copy in the new address */
>  		ether_addr_copy(dev->dev_addr, addr);
>  	} else {
> 
