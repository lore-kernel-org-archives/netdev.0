From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH] amd-xgbe: fix potential memory leak in xgbe-debugfs
Date: Wed, 30 Sep 2015 09:06:47 -0500
Message-ID: <560BEC77.8010400@amd.com>
References: <636eed156113df40f9dd5e696f0486f428aff590.1443638366.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0077.outbound.protection.outlook.com ([65.55.169.77]:10496
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752578AbbI3OG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:06:59 -0400
In-Reply-To: <636eed156113df40f9dd5e696f0486f428aff590.1443638366.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2015 05:48 AM, Geliang Tang wrote:
> Added kfree() to avoid the memory leak when debugfs_create_dir() fails.
>
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Acked-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>   drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
> index 2c063b6..66137ff 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
> @@ -330,6 +330,7 @@ void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
>   	pdata->xgbe_debugfs = debugfs_create_dir(buf, NULL);
>   	if (!pdata->xgbe_debugfs) {
>   		netdev_err(pdata->netdev, "debugfs_create_dir failed\n");
> +		kfree(buf);
>   		return;
>   	}
>
>

Looking at the code, I should also check for buf being NULL before
calling debugfs_create_dir. I'll work up a patch for that and send
it in.

Thanks,
Tom
