From: Ed Swierk <eswierk@aristanetworks.com>
Subject: Re: [Regression, in, 2.6.29] forcedeth doesn't work after resume
 from hibernation (was: Re: Resume after hibernation regression in 2.6.29)
Date: Mon, 06 Apr 2009 07:03:32 -0700
Message-ID: <1239026612.23068.1.camel@localhost.localdomain>
References: <20090404.165421.142076064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:46938 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206AbZDFODk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 10:03:40 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2250967wff.4
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2009 07:03:39 -0700 (PDT)
In-Reply-To: <20090404.165421.142076064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-04-04 at 16:54 -0700, David Miller wrote:
> Please send a version of this patch that actually applies to
> Linus's tree, the line numbers et al. are a lot different
> now.
> 
> I'll backport and submit that to -stable.
> 
> Thanks.

Reset phy state on resume, fixing a regression caused by powering down
the phy on hibernate.

Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>
---
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a858c6f..663a7b3 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -6117,6 +6117,9 @@ static int nv_resume(struct pci_dev *pdev)
 
 	pci_write_config_dword(pdev, NV_MSI_PRIV_OFFSET, NV_MSI_PRIV_VALUE);
 
+	/* restore phy state, including autoneg */
+	phy_init(dev);
+
 	netif_device_attach(dev);
 	if (netif_running(dev)) {
 		rc = nv_open(dev);


