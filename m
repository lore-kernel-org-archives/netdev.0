From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Subject: RE: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC interrupt may not be shared
Date: Fri, 29 May 2009 12:12:49 +0100
Message-ID: <8A42379416420646B9BFAC9682273B6D0B43DCCD@limkexm3.ad.analog.com>
References: <1243404615-25879-2-git-send-email-vapier@gentoo.org><20090529.020122.110502272.davem@davemloft.net><8bd0f97a0905290349p6f52d170i3714cd3ec0c81817@mail.gmail.com> <20090529.035344.92579416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <uclinux-dist-devel@blackfin.uclinux.org>
To: "David Miller" <davem@davemloft.net>, <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:47230 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982AbZE2LMu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:12:50 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <20090529.035344.92579416.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>From: David Miller [mailto:davem@davemloft.net]
>From: Mike Frysinger <vapier.adi@gmail.com>
>Date: Fri, 29 May 2009 06:49:42 -0400
>
>> the hardware has a dedicated internal IRQ line for the Blackfin MAC.
>> it makes no sense to mark it as shared.  there is nothing it could
>> possibly be shared with.
>
>Then why bother messing with the flag away at all?  It doesn't fix
>anything.

Well - it fixes a bug seen with CONFIG_DEBUG_SHIRQ.
CONFIG_DEBUG_SHIRQ generates spurious fake interrupts and 
checks if the handler can cope with them. 
This is basically a good thing - however only for real shared
interrupts.

Our handler isn't prepared to handle such fake interrupts.
So two options:
1) Set the proper IRQF flags.
2) Fix the ISR to handle spurious interrupts.

This patch chose option 1) 

-Michael 
 
