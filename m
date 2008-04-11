From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
Date: Fri, 11 Apr 2008 14:11:44 -0500
Message-ID: <47FFB7F0.5030206@freescale.com>
References: <1207870471-3601-1-git-send-email-afleming@freescale.com> <20080411153125.GA2588@loki.buserror.net> <1D6963B0-4EC5-41F7-8BFA-97C2C0647A13@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	linuxppc-dev@ozlabs.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:48414 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760249AbYDKTL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 15:11:26 -0400
In-Reply-To: <1D6963B0-4EC5-41F7-8BFA-97C2C0647A13@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> I tried.  Technically, we can.  But the issue is that struct gfar 
> *enet_regs->gfar_mii_regs is declared:
> 
> u8 gfar_mii_regs[24];
> 
> I could not find any sequence of castings that made the warning go away 
> about casting that to a struct gfar_mii __iomem *.  And that includes 
> mucking around with the declaration of gfar_mii_regs.  I vaguely recall 
> determining that you couldn't make it a struct, because you can't 
> guarantee gcc won't much with the size of the struct.  Or something.  

We use structs for registers all over the place.  The only time GCC 
should mess with struct layout is if fields aren't aligned as required 
by the ABI (and in that case, use the packed attribute).

-Scott
