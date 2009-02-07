From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG BISECTED] boot hangs while bringing up gianfar ethernet
Date: Sat, 7 Feb 2009 23:55:56 +0100
Message-ID: <20090207225555.GA2680@ami.dom.local>
References: <20090129194145.GA4647@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:36693 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbZBGWzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 17:55:03 -0500
Content-Disposition: inline
In-Reply-To: <20090129194145.GA4647@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ira Snyder wrote, On 01/29/2009 08:41 PM:

> Hello,
> 
> I'm working on a Freescale MPC8349EMDS board. I have been booting it
> over NFS for a long time now. I try to run the latest git kernels to
> find possible problems.
> 
> Recently, I haven't been able to boot over NFS anymore. When the machine
> tries to bring up the ethernet interface, it just hangs forever. There
> are no softlockup warnings, the machine has locked up completely.
> 
> Here is the commit I bisected it down to. I tried running git revert,
> but there have been other changes which prevent an easy revert.
> 
> After building each kernel, I compiled and used the dts file from that
> kernel. There shouldn't be any conflicts there.
> 
> I'm happy to test patches to fix the problem.
> 
> Thanks,
> Ira
> 
> 8c7396aebb68994c0519e438eecdf4d5fa9c7844 is first bad commit
> commit 8c7396aebb68994c0519e438eecdf4d5fa9c7844
> Author: Dai Haruki <dai.haruki@freescale.com>
> Date:   Wed Dec 17 16:52:00 2008 -0800
> 
>     gianfar: Merge Tx and Rx interrupt for scheduling clean up ring

Hi,

Could you try this patch?

Thanks,
Jarek P.
---

 drivers/net/gianfar.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index acae2d8..1335d89 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1629,6 +1629,8 @@ static void gfar_schedule_cleanup(struct net_device *dev)
 	if (netif_rx_schedule_prep(&priv->napi)) {
 		gfar_write(&priv->regs->imask, IMASK_RTX_DISABLED);
 		__netif_rx_schedule(&priv->napi);
+	} else {
+		gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
 	}
 
 	spin_unlock(&priv->rxlock);
