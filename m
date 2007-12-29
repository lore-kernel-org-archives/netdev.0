From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Make FC, FDDI, HIPPI and TR tristate
Date: Sat, 29 Dec 2007 01:41:23 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712290140090.29013@fbirervta.pbzchgretzou.qr>
References: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr>
 <20071229000930.GD9105@does.not.exist>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:44677 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbXL2AlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 19:41:25 -0500
In-Reply-To: <20071229000930.GD9105@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 29 2007 02:09, Adrian Bunk wrote:
>On Sat, Dec 29, 2007 at 12:45:12AM +0100, Jan Engelhardt wrote:
>> Turn CONFIG_FC, CONFIG_FDDI, CONFIG_HIPPI and CONFIG_TR into tristate
>> so they can be built as modules. This will allow CONFIG_LLC to be
>> built as a module too, overall reducing the core kernel image size.
>>...
>
>Just an example of code you have to fix if you do this:
>
>$ grep -r "#ifdef CONFIG_TR" net/

Ah, thank you for reminding me. For lec.c, would it be ok to do

#if defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
#	define WITH_TR 1
#endif

at the top and then do a s/CONFIG_TR/WITH_TR/? Just so that the #ifdef
lines do not explode in redundance.

>net/802/sysctl_net_802.c:#ifdef CONFIG_TR
>net/802/sysctl_net_802.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/atm/lec.c:#ifdef CONFIG_TR
>net/ipv4/arp.c:#ifdef CONFIG_TR
>net/llc/llc_output.c:#ifdef CONFIG_TR
>net/sysctl_net.c:#ifdef CONFIG_TR
>net/sysctl_net.c:#ifdef CONFIG_TR
>$ 
