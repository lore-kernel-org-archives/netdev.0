From: Hyong-Youb Kim <hyong-youb.kim@myricom.com>
Subject: Re: [PATCH v2] myri10ge: check for DMA mapping errors
Date: Tue, 12 Aug 2014 19:04:24 +0900
Message-ID: <53E9E6A8.2060908@myricom.com>
References: <20140812083518.GA1836@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hyong-Youb Kim <hykim@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:10723
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751155AbaHLKFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 06:05:00 -0400
In-Reply-To: <20140812083518.GA1836@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 8/12/2014 5:35 PM, Stanislaw Gruszka wrote:
> On IOMMU systems DMA mapping can fail, we need to check for
> that possibility.
>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> v1 -> v2: check also for errors on myri10ge_xmit()

It looks okay to me.

>   abort_linearize:
[...]
> -	tx->info[idx].skb = NULL;

I think this last line was a bug.  Thanks for fixing this too.  It would 
lead the code below to call pci_unmap_page() on the header buffer.  It 
should call pci_unmap_single() instead.

> -	do {
[...]
> -			if (tx->info[idx].skb != NULL)
> -				pci_unmap_single(mgp->pdev,
[...]
> -			else
> -				pci_unmap_page(mgp->pdev,
