From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix for SR-IOV VF initialization
Date: Tue, 22 Jul 2014 15:34:40 -0700 (PDT)
Message-ID: <20140722.153440.757089942973087670.davem@davemloft.net>
References: <1406026580-27256-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932783AbaGVWel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 18:34:41 -0400
In-Reply-To: <1406026580-27256-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 22 Jul 2014 16:26:20 +0530

> Commit 35b1de5 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is exposed
> through PCI Passthrough") introduced a regression, where VF failed to
> initialize. This commit fixes it.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

This commit message need to explain things better, how exactly was
the regression introduced, what's exactly wrong with the current code?

I actually can't figure it out myself, other than to say that maybe
replacing things with:

	func = PCI_FUNC(pdev->devfn);
 	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
 		if (pci_enable_sriov(pdev, num_vf[func]) == 0)

would work equally as well.  That's precisely what the code was
doing before the mentioned commit.

Why do we have to iterate over _ALL_ functions of the PCI device,
rather than just directly enable SRIOV on the one function whether
it bet PCI_FUNC(pdev->devfn) or that WHOAMI value?

You need to explain this so that people understand the how and the
why of your changes.

Thanks.
