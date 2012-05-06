From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] bnx2x: bug fix when loading after SAN boot
Date: Sun, 06 May 2012 13:11:01 -0400 (EDT)
Message-ID: <20120506.131101.1315377899936868892.davem@davemloft.net>
References: <1336323957.12363.23.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab2EFRLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 13:11:04 -0400
In-Reply-To: <1336323957.12363.23.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Sun, 6 May 2012 20:05:57 +0300

> From: Ariel Elior <ariele@broadcom.com>
> 
> This is a bug fix for an "interface fails to load" issue.
> The issue occurs when bnx2x driver loads after UNDI driver was previously
> loaded over the chip. In such a scenario the UNDI driver is loaded and operates
> in the pre-boot kernel, within its own specific host memory address range.
> When the pre-boot stage is complete, the real kernel is loaded, in a new and
> distinct host memory address range. The transition from pre-boot stage to boot
> is asynchronous from UNDI point of view.
> 
> A race condition occurs when UNDI driver triggers a DMAE transaction to valid
> host addresses in the pre-boot stage, when control is diverted to the real
> kernel. This results in access to illegal addresses by our HW as the addresses
> which were valid in the preboot stage are no longer considered valid.
> Specifically, the 'was_error' bit in the pci glue of our device is set. This
> causes all following pci transactions from chip to host to timeout (in
> accordance to the pci spec).
> 
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
