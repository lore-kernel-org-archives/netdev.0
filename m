From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Fix compilation when CONFIG_PCI_IOV is
 not defined
Date: Wed, 02 Jan 2013 18:47:28 -0800 (PST)
Message-ID: <20130102.184728.810047795466238734.davem@davemloft.net>
References: <1357133785-9569-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab3ACCrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 21:47:31 -0500
In-Reply-To: <1357133785-9569-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Wed, 2 Jan 2013 15:36:25 +0200

> This patch ifdefs out the use of PCI_IOV_RESOURCES which exists in the
> kernel only when CONFIG_PCI_IOV is defined. There is no point in doing
> the same for the invocation of SRIOV functionality in the driver as it
> will be immediately failed by a kernel which was thus compiled.
> 
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

This fixes the build but this is a very disappointing patch.

None of your SR-IOV support can possibly work if CONFIG_PCI_IOV
is not set.

Look at how the SFC driver has a special Kconfig option and elides
all of it's SR-IOV code when that Kconfig option is not set.

That kind of Kconfig option is where you express the CONFIG_PCI_IOV
dependency, rather than in a hackish way with ifdefs as a knee-jerk
response to a build failure reports.

I'm not applying this patch, segregate your driver properly and use
Kconfig dependencies to elide the building of all of the SR-IOV
support code in this driver.
