From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: via velocity trivial patch
Date: Fri, 8 May 2009 21:29:48 +0200
Message-ID: <20090508192948.GA19016@electric-eye.fr.zoreil.com>
References: <49F1A05A.8070802@podgorny.cz> <4A01FBF6.1090001@podgorny.cz> <20090507.150213.192379856.davem@davemloft.net> <4A04184E.5040507@podgorny.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Radek Podgorny <radek@podgorny.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40095 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755133AbZEHT3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 15:29:05 -0400
Content-Disposition: inline
In-Reply-To: <4A04184E.5040507@podgorny.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radek Podgorny <radek@podgorny.cz> :
[...]
> Anyway, I've verified this is really happening on my hardware when
> multiple via velocity devices share the same interrupt. The one the
> interrupt is for reads the correct ISR value, the others sometimes read
> 0 and sometimes 0xffffffff. I'm not educated enough to tell why.

Your quad port network card includes its own pci bus, right ?
If so can you send a 'lspci -vt' of the host ?

> Reasons to include the fix:
> 1) Someone smarter than me suggested it (Jeff Garzik).
> 2) Fixed my problem.
> 3) Does not introduce a new problem.

3. probably stands: there is no reason for the driver to see a
0xffffffff interupt status register (hardware fault or unplug apart).

Well, almost:

$ grep mac.*isr drivers/net/via-velocity.h
#define mac_read_isr(regs)              readl(&((regs)->ISR))
#define mac_write_isr(regs, x)          writel((x),&((regs)->ISR))
#define mac_clear_isr(regs)             writel(0xffffffffL,&((regs)->ISR))

I can figure that there is a window through which the 2nd, 3rd and 4th
devices can read a 0xffffffff when they are brought up but it should
not be noticeable after this stage (and it may happen on the 1st device
as well if it shares its interrupt with some other device).

Does it match your experience ?

> So I'm attaching the patch again. Now with the proper sign-off.

davem's life is probably simpler if you do not include anything
after the patch.

-- 
Ueimor
