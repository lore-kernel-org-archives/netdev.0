From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] net-tg3: Initialize REG_BASE_ADDR at PCI config offset
 120 to 0
Date: Mon, 9 Dec 2013 11:00:08 -0800
Message-ID: <1386615608.1752.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1386614601-9453-1-git-send-email-natg@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <nsujir@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Nat Gurumoorthy <natg@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:27660 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966Ab3LITJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 14:09:46 -0500
In-Reply-To: <1386614601-9453-1-git-send-email-natg@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-09 at 10:43 -0800, Nat Gurumoorthy wrote: 
> The new tg3 driver leaves REG_BASE_ADDR (PCI config offset 120)
> uninitialized. From power on reset this register may have garbage in it. The
> Register Base Address register defines the device local address of a
> register. The data pointed to by this location is read or written using
> the Register Data register (PCI config offset 128). When REG_BASE_ADDR has
> garbage any read or write of Register Data Register (PCI 128) will cause the
> PCI bus to lock up. The TCO watchdog will fire and bring down the system.
> 
> 
Is this to prevent problem from other software that may be scanning the
PCI config space?  It won't help if this happens before the tg3 driver
is loaded, right?

Thanks.
