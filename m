From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [E1000-devel] [PATCH net v3 2/2] e100: Add netif_napi_del in
 the driver
Date: Fri, 26 Dec 2014 12:27:16 -0800
Message-ID: <20141226122716.138fe916@urahara>
References: <1419472956-6270-1-git-send-email-baijiaju1990@163.com>
	<1419472956-6270-2-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux.nics@intel.com
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:59502 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaLZU13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 15:27:29 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so13745174pad.10
        for <netdev@vger.kernel.org>; Fri, 26 Dec 2014 12:27:28 -0800 (PST)
In-Reply-To: <1419472956-6270-2-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Dec 2014 10:02:36 +0800
Jia-Ju Bai <baijiaju1990@163.com> wrote:

> The driver lacks netif_napi_del in the normal path and error path to 
> match the call of netif_napi_add in e100_probe.
> This patch fixes this problem, and it has been tested on the hardware.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/net/ethernet/intel/e100.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
> index 781065e..21c4d0f 100644
> --- a/drivers/net/ethernet/intel/e100.c
> +++ b/drivers/net/ethernet/intel/e100.c
> @@ -2985,6 +2985,7 @@ err_out_free_res:
>  err_out_disable_pdev:
>  	pci_disable_device(pdev);
>  err_out_free_dev:
> +	netif_napi_del(&nic->napi);
>  	free_netdev(netdev);

This is unnecessary since already done in free_netdev()

void free_netdev(struct net_device *dev)
{
..	
	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
		netif_napi_del(p);
.
