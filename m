From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM
	driver to request_firmware()
Date: Mon, 30 Jun 2008 20:18:12 +0100
Message-ID: <1214853492.10393.350.camel@pmac.infradead.org>
References: <200806301610.m5UGAlqr025302@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:57358 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbYF3TSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 15:18:20 -0400
In-Reply-To: <200806301610.m5UGAlqr025302@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-30 at 12:10 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1214837678.10393.345.camel@pmac.infradead.org>,David Woodhouse writ
> es:
> >> i removed the #ifdef's from around MODULE_LICENSE().  there shouldnt
> >> be any need for #ifdef's around MODULE_FIRMWARE() either.
> >
> >Unless you put #ifdef CONFIG_SBUS around the
> >MODULE_FIRMWARE("sba200e_ecd.bin") you will be requesting that firmware
> >even on non-sbus machines. Likewise little-endian vs. big-endian on PCI.
> 
> does it?  i was under the impression that MODULE_FIRMWARE() just
> provides a hint that modinfo can read.  request_firmware() still
> the requestor for the firmware image.

True. But if you were to put the driver into an initrd, for example,
then the tools would pick out all three firmwares to include in the
initrd too. Given that we _do_ know at runtime that we'll need a maximum
of two of the three, it makes sense to list only the ones we might use.

-- 
dwmw2

