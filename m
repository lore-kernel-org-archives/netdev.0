From: Pavel Belous <pavel.belous@aquantia.com>
Subject: Re: [PATCH v2] net: ethernet: aquantia: set net_device mtu when mtu
 is changed
Date: Fri, 10 Mar 2017 01:01:43 +0300
Message-ID: <de515967-c656-e025-82c6-9c14f590a3ea@aquantia.com>
References: <1489093426-25733-1-git-send-email-darcari@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Arcari <darcari@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0076.outbound.protection.outlook.com ([104.47.34.76]:21873
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752466AbdCIWB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 17:01:59 -0500
In-Reply-To: <1489093426-25733-1-git-send-email-darcari@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10.03.2017 00:03, David Arcari wrote:
> When the aquantia device mtu is changed the net_device structure is not
> updated.  As a result the ip command does not properly reflect the mtu change.
>
> Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
> assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
> has a ndo_change_mtu routine.
>
> Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")
>
> v2: no longer close/open net-device after mtu change
>
> Cc: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: David Arcari <darcari@redhat.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_main.c | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> index dad6362..bba5ebd 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
> @@ -96,15 +96,9 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
>  	struct aq_nic_s *aq_nic = netdev_priv(ndev);
>  	int err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
>
> -	if (err < 0)
> -		goto err_exit;
> +	if (!err)
> +		ndev->mtu = new_mtu;
>
> -	if (netif_running(ndev)) {
> -		aq_ndev_close(ndev);
> -		aq_ndev_open(ndev);
> -	}
> -
> -err_exit:
>  	return err;
>  }
>
>

Tested-by: Pavel Belous <pavel.belous@aquantia.com>
