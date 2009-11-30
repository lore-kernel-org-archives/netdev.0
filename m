From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: EEH is failing with timeout
Date: Mon, 30 Nov 2009 01:40:58 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218065B984E@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1259256709-6976-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'leitao@linux.vnet.ibm.com'" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3896 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752374AbZK3Jk7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 04:40:59 -0500
In-Reply-To: <1259256709-6976-1-git-send-email-leitao@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

leitao@linux.vnet.ibm.com wrote:

> bnx2 is failing when a PCI error is detected. The error is the
> following:
>
> bnx2: Chip not in correct endian mode
> bnx2: fw sync timeout, reset code = 404001d
>
> This error was caused because the way pci_restore_state() is working
> after commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff.
>
> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>

Thanks Breno.

Acked by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/bnx2.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 08cddb6..7fa4048 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -8264,6 +8264,7 @@ static pci_ers_result_t
> bnx2_io_slot_reset(struct pci_dev *pdev)
>       }
>       pci_set_master(pdev);
>       pci_restore_state(pdev);
> +     pci_save_state(pdev);
>
>       if (netif_running(dev)) {
>               bnx2_set_power_state(bp, PCI_D0);
> --
> 1.6.0.2
>
>
>

