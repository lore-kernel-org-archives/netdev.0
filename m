From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH] net: ethernet: aquantia: set net_device mtu when mtu is
 changed
Date: Tue, 14 Mar 2017 04:32:38 +0300
Message-ID: <a0284a60-e33d-389e-3798-bd8827424cb0@aquantia.com>
References: <1489446436-42246-1-git-send-email-darcari@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Arcari <darcari@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0067.outbound.protection.outlook.com ([104.47.36.67]:43008
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751655AbdCNBcx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 21:32:53 -0400
In-Reply-To: <1489446436-42246-1-git-send-email-darcari@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/14/2017 02:07 AM, David Arcari wrote:
> When the aquantia device mtu is changed the net_device structure is not
> updated.  As a result the ip command does not properly reflect the mtu change.
>
> Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
> assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
> has a ndo_change_mtu routine.
>
> Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")
>
> Cc: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: David Arcari <darcari@redhat.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> index dad6362..d05fbfd 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> @@ -98,6 +98,7 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
>
>  	if (err < 0)
>  		goto err_exit;
> +	ndev->mtu = new_mtu;
>
>  	if (netif_running(ndev)) {
>  		aq_ndev_close(ndev);
>

Tested-by: Pavel Belous <pavel.belous@aquantia.com>
