From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V2 1/2] e100 in linux-3.18.0: Fix null pointer deference
 in e100_probe
Date: Sun, 21 Dec 2014 17:02:33 +0300
Message-ID: <5496D2F9.4070306@cogentembedded.com>
References: <000201d01c61$bdb956b0$392c0410$@163.com> <20141220.143005.1130435723139487537.davem@davemloft.net> <5496203F.9000000@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: todd.fujinaka@intel.com, Linux-nics@isotope.jf.intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net
To: Jia-Ju Bai <baijiaju1990@163.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35138 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbaLUOCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 09:02:35 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so2774330lbv.25
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 06:02:33 -0800 (PST)
In-Reply-To: <5496203F.9000000@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2014 4:19 AM, Jia-Ju Bai wrote:

    Please don't send HTML to this mailing list -- your mail may be ignored by 
the list server.

> The driver lacks the check of nic->cbs_pool after pci_pool_create in e100_probe. So when this function is failed, the null pointer dereference occurs when pci_pool_alloc uses nic->cbs_pool in e100_alloc_cbs.

    Same comment as for the previous patch about wrapping at 80 columns.

> This patch fix this problem, and it has been tested in runtime.

> Signed-off-by: Jia-Ju Bai<baijiaju1990@163.com>
> ---
>   drivers/net/ethernet/intel/e100.c     |   6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
> index 781065e..ba1813f 100644
> --- a/drivers/net/ethernet/intel/e100.c
> +++ b/drivers/net/ethernet/intel/e100.c
> @@ -2969,6 +2969,10 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>                 nic->params.cbs.max * sizeof(struct cb),
>                 sizeof(u32),
>                 0);
> +   if (!nic->cbs_pool) {
> +       err = -ENOMEM;
> +       goto err_out_pool;
> +   }

    Looks like tabs got converted to spaces by your mailer, thus the patch 
can't be applied. Consider using 'git send-email' instead.

[...]

WBR, Sergei
