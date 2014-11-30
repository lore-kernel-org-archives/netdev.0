From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] sky2: avoid pci write posting after disabling irqs
Date: Sun, 30 Nov 2014 09:54:20 -0800
Message-ID: <20141130095420.53375231@urahara>
References: <1417348611-1752-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34477 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbaK3Rya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 12:54:30 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so9387610pdi.16
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 09:54:29 -0800 (PST)
In-Reply-To: <1417348611-1752-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Nov 2014 12:56:51 +0100
Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:

> In sky2_change_mtu setting B0_IMSK to 0 may be delayed due to PCI write posting
> which could result in irqs being still active when synchronize_irq is called.
> Since we are not prepared to handle any further irqs after synchronize_irq
> (our resources are freed after that) force the write by a consecutive read from
> the same register.
> Similar situation in sky2_all_down: Here we disabled irqs by a write to B0_IMSK
> but did not ensure that this write took place before synchronize_irq. Fix that
> too.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Looks correct.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
