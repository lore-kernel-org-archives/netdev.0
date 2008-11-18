From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [atl1-devel] atl2: don't mess up irq on suspend/resume
 (probably msi only)
Date: Mon, 17 Nov 2008 18:13:36 -0600
Message-ID: <20081117181336.1a270561@osprey.hogchain.net>
References: <49201401.1060600@tuffmail.co.uk>
	<4921E574.3090602@tuffmail.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, atl1-devel@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:7071 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbYKRANn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 19:13:43 -0500
Received: by rv-out-0506.google.com with SMTP id k40so2659662rvb.1
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 16:13:42 -0800 (PST)
In-Reply-To: <4921E574.3090602@tuffmail.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding netdev to cc list]

On Mon, 17 Nov 2008 21:43:16 +0000
Alan Jenkins <alan-jenkins@tuffmail.co.uk> wrote:


> Don't listen to me.  The problem went away because when I was testing
> my patch, I plugged the ethernet in and actually used it.  My patch
> doesn't seem to fix anything.
> 
> So I now have the steps to reproduce this warning: remove the ethernet
> cable and suspend.
> 
> Also, I was speaking rubbish because the warning isn't on the resume
> path.  It seems to be when network-manager re-opens the device on
> resume.
> 
> I'll have another look for possible culprits.  Hints appreciated :).

Does this help?

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index f5bdc92..5b292f0 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1690,10 +1690,6 @@ static int atl2_resume(struct pci_dev *pdev)
 
 	ATL2_WRITE_REG(&adapter->hw, REG_WOL_CTRL, 0);
 
-	err = atl2_request_irq(adapter);
-	if (netif_running(netdev) && err)
-		return err;
-
	atl2_reset_hw(&adapter->hw);
 
	if (netif_running(netdev))
