From: Timur Tabi <timur@freescale.com>
Subject: Re: Kconfig warnings on latest GIT
Date: Thu, 10 May 2007 11:56:48 -0500
Message-ID: <46434ED0.6030808@freescale.com>
References: <200705080004.14570.ismail@pardus.org.tr> <20070508143127.38fafa3c.kim.phillips@freescale.com> <4640D988.1040504@freescale.com> <20070510051042.GA16812@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kim Phillips <kim.phillips@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ismail_D=F6nmez?= <ismail@pardus.org.tr>,
	Kumar Gala <galak@kernel.crashing.org>,
	Michael Schmitz <schmitz@debian.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:42830 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952AbXEJQ7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 12:59:03 -0400
In-Reply-To: <20070510051042.GA16812@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:

>> So my question is: in which Kconfig do I define "UCC_FAST_TEMP" and 
>> "UCC_SLOW_TEMP"?  At first I thought, just put it in drivers/Kconfig, but that 
>> Kconfig does nothing but including other Kconfigs.  I believe that if I submit 
>> a patch that adds "UCC_FAST_TEMP" and "UCC_SLOW_TEMP" to drivers/Kconfig, it 
>> will be rejected.  Either that, or I'll spend six weeks trying to persuade 
>> everyone that it's a good idea.
>>
>> Does anyone have any suggestions on how I can fix this?
> 
> That does seem like a reasonable suggestion, and one that
> would probably work well with the other similar problems
> that have been introduced sice 2.6.21.

Looks like the fix is simpler than I thought.  Instead of having

UCC_GETH
	select UCC_FAST

I need to do

UCC_FAST
	default y if UCC_GETH

I'll have a patch that fixes this out later today.

I chose the first method because I wanted each individual UCC device driver to select 
UCC_FAST or UCC_SLOW as appropriate, so that I wouldn't have to update 
arch/powerpc/sysdev/qe_lib/Kconfig every time we add a new UCC driver.  Oh well.

-- 
Timur Tabi
Linux Kernel Developer @ Freescale
