From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 5/8] net: qualcomm: move MTU handling to
 qca_common
Date: Tue, 18 Oct 2016 14:29:16 -0400 (EDT)
Message-ID: <20161018.142916.930441148920074337.davem@davemloft.net>
References: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
        <1476790054-27174-6-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, jslaby@suse.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45266 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932480AbcJRS3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:29:18 -0400
In-Reply-To: <1476790054-27174-6-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue, 18 Oct 2016 13:27:31 +0200

> The MTU of the QCA7000 is independent from it's host interface (UART,SPI).
> So move the change_mtu function to qca_common.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  drivers/net/ethernet/qualcomm/qca_common.c | 11 +++++++++++
>  drivers/net/ethernet/qualcomm/qca_common.h |  3 +++
>  drivers/net/ethernet/qualcomm/qca_spi.c    | 13 +------------
>  3 files changed, 15 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qualcomm/qca_common.c b/drivers/net/ethernet/qualcomm/qca_common.c
> index 26453a9..9020c57 100644
> --- a/drivers/net/ethernet/qualcomm/qca_common.c
> +++ b/drivers/net/ethernet/qualcomm/qca_common.c
> @@ -154,3 +154,14 @@ qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_by
>  
>  	return ret;
>  }
> +
> +int
> +qcacmn_netdev_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	if ((new_mtu < QCAFRM_ETHMINMTU) || (new_mtu > QCAFRM_ETHMAXMTU))
> +		return -EINVAL;

In net-next this limiting is implemented by the driver properly setting
netdev->min_mtu and netdev->max_mtu respectively.

And once you do that, you no longer need this method at all.
