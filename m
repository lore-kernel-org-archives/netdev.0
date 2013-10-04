From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 01/10] qlcnic: Print informational messages
 only once during driver load.
Date: Fri, 4 Oct 2013 14:29:38 -0700
Message-ID: <20131004142938.4ab6c6aa@nehalam.linuxnetplumber.net>
References: <cover.1380937706.git.himanshu.madhani@qlogic.com>
	<5fea5316a6664e19c516bbd26428a5034657b130.1380937706.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46145 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab3JDV3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 17:29:42 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so4507811pbb.5
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 14:29:42 -0700 (PDT)
In-Reply-To: <5fea5316a6664e19c516bbd26428a5034657b130.1380937706.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Oct 2013 14:30:48 -0400
Himanshu Madhani <himanshu.madhani@qlogic.com> wrote:

> From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 +
>  .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 12 -----------
>  .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  | 25 ++++++++++++++++++----
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  1 +
>  4 files changed, 23 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> index 81bf836..a3c4379 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> @@ -1199,6 +1199,7 @@ struct qlcnic_npar_info {
>  	u8	promisc_mode;
>  	u8	offload_flags;
>  	u8      pci_func;
> +	u8      mac[ETH_ALEN];
>  };
>  

>  

There is a field in netdevice which should probably be used for this perm_addr.

And then this could be corrected:

static void qlcnic_dcb_get_perm_hw_addr(struct net_device *netdev, u8 *addr)
{
	memcpy(addr, netdev->dev_addr, netdev->addr_len);
}
