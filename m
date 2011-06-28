From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/19 v2] tg3: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 21:39:32 -0700 (PDT)
Message-ID: <20110627.213932.828761097349347608.davem@davemloft.net>
References: <1309196854-16232-1-git-send-email-jdmason@kudzu.us>
	<20110627225649.GA20786@kudzu.us>
	<20110627233352.GA6223@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: mcarlson@broadcom.com, jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900Ab1F1Ejg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:39:36 -0400
In-Reply-To: <20110627233352.GA6223@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>, "Jon Mason" <jdmason@kudzu.us>
Date: Mon, 27 Jun 2011 16:33:52 -0700

> On Mon, Jun 27, 2011 at 03:56:50PM -0700, Jon Mason wrote:
>> The PCIE capability offset is saved during PCI bus walking.  Use the
>> value from pci_dev instead of checking in the driver and saving it off
>> the the driver specific structure.  It will remove an unnecessary search
>> in the PCI configuration space if this value is referenced instead of
>> reacquiring it.
>> 
>> v2 of the patch re-adds the PCI_EXPRESS flag and adds comments
>> describing why it is necessary.
>> 
>> Signed-off-by: Jon Mason <jdmason@kudzu.us>
...
> Sorry to be a stickler, but can we convert all occurances of
> 'tp->pdev->pcie_cap' to pci_pcie_cap(tp->pdev)?  If the PCI layer is
> taking control of that variable, the driver shouldn't be accessing it
> directly if it can help it.

I did this while adding this patch, thanks.
