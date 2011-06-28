From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH] [v3][net][bna] Fix call trace when interrupts are
 disabled while sleeping function kzalloc is called
Date: Tue, 28 Jun 2011 16:32:58 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A82D66F782@HQ1-EXCH01.corp.brocade.com>
References: <1309287485-6077-1-git-send-email-shyam_iyer@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Debashis Dutt <ddutt@Brocade.COM>, Jing Huang <huangj@Brocade.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Shyam Iyer <shyam_iyer@dell.com>
To: Shyam Iyer <shyam.iyer.t@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52637 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751854Ab1F1XdL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 19:33:11 -0400
In-Reply-To: <1309287485-6077-1-git-send-email-shyam_iyer@dell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Shyam Iyer [mailto:shyam.iyer.t@gmail.com]
>Sent: Tuesday, June 28, 2011 11:58 AM
>
>request_threaded irq will call kzalloc that can sleep. Initializing the
>flags variable outside of spin_lock_irqsave/restore in
>bnad_mbox_irq_alloc will avoid call traces like below.
>
>@@ -1125,18 +1125,17 @@ bnad_mbox_irq_alloc(struct bnad *bnad,
> 	if (bnad->cfg_flags & BNAD_CF_MSIX) {
> 		irq_handler = (irq_handler_t)bnad_msix_mbox_handler;
> 		irq = bnad->msix_table[bnad->msix_num - 1].vector;
>-		flags = 0;
> 		intr_info->intr_type = BNA_INTR_T_MSIX;
> 		intr_info->idl[0].vector = bnad->msix_num - 1;
> 	} else {
> 		irq_handler = (irq_handler_t)bnad_isr;
> 		irq = bnad->pcidev->irq;
>-		flags = IRQF_SHARED;
>+		irq_flags = IRQF_SHARED;
> 		intr_info->intr_type = BNA_INTR_T_INTX;
> 		/* intr_info->idl.vector = 0 ? */
> 	}
> 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
>-
>+	flags = irq_flags;
> 	sprintf(bnad->mbox_irq_name, "%s", BNAD_NAME);
>
> 	/*

Patch looks fine.

Acked-by: Rasesh Mody <rmody@brocade.com>
