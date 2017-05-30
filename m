From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: avoid crash on PCI error recovery path
Date: Tue, 30 May 2017 12:16:30 -0400 (EDT)
Message-ID: <20170530.121630.85776802788069421.davem@davemloft.net>
References: <20170529020701.27765-1-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, muvic@linux.vnet.ibm.com,
        porcusbr@gmail.com, ganeshgr@chelsio.com, hariprasad@chelsio.com
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52818 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751118AbdE3QQi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:16:38 -0400
In-Reply-To: <20170529020701.27765-1-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Sun, 28 May 2017 23:07:01 -0300

> During PCI error recovery process, specifically on eeh_err_detected()
> we might have a NULL netdev struct, hence a direct dereference will
> lead to a kernel oops. This was observed with latest upstream kernel
> (v4.12-rc2) on Chelsio adapter T422-CR in PowerPC machines.
> 
> This patch checks for NULL pointer and avoids the crash, both in
> eeh_err_detected() and eeh_resume(). Also, we avoid to trigger
> a fatal error or to try disabling interrupts on FW during PCI
> error recovery, because: (a) driver might not be able to accurately
> access PCI regions in this case, and (b) trigger a fatal error
> _during_ the recovery steps is a mistake that could prevent the
> recovery path to complete successfully.
> 
> Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Applied, thanks.
