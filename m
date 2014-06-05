From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/4] macvlan: don't update the uc and vlan list
 for L2 forwarding offload
Date: Thu, 05 Jun 2014 09:52:26 -0400
Message-ID: <5390761A.5030808@gmail.com>
References: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com> <1401951028-9800-2-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>, kaber@trash.net,
	davem@davemloft.net, edumazet@google.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:38644 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaFENwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 09:52:30 -0400
Received: by mail-qa0-f51.google.com with SMTP id w8so1379386qac.24
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 06:52:29 -0700 (PDT)
In-Reply-To: <1401951028-9800-2-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2014 02:50 AM, Ding Tianhong wrote:
> If lowerdev supports L2 forwarding offload, no need to set mac address
> to uc list and vlan list, so also don't do that when the macvlan mac address
> changes.
> 

Are you sure about this?  How would the lower dev receive traffic
destined to the new HW address if it is not in the device unicast filter
list?

-vlad

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
