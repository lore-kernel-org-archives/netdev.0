From: Scott Wood <scottwood@freescale.com>
Subject: Re: WARN_ON() hit in fsl bitbanged phy driver
Date: Mon, 11 Feb 2008 15:50:02 -0600
Message-ID: <47B0C30A.1030801@freescale.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B03F931E6@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Rune Torgersen <runet@innovsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:52482 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143AbYBKVuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 16:50:21 -0500
In-Reply-To: <DCEAAC0833DD314AB0B58112AD99B93B03F931E6@ismail.innsys.innovsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rune Torgersen wrote:
> I hit the following WARN_ON when using mii-tools agains a ethernet
> interface using a bit-banged mii interface
> It is only diplayed once, and does not seem to impact usage at all
> 
> Does somebody know what is wrong, and how to fix it?

It looks like the kernel thinks it's in an interrupt, even though it 
clearly isn't from the backtrace.  Presumably, something slept from an 
interrupt handler; try turning on sleep-in-spinlock debugging.

The root cause was probably something other than the phy code.

-Scott
