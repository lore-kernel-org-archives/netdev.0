From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Thu, 15 Aug 2013 00:47:36 +0200
Message-ID: <20130814224736.GA5193@electric-eye.fr.zoreil.com>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com>
 <3465288.NFVErF5E7l@al>
 <20130814195829.GA1613@electric-eye.fr.zoreil.com>
 <2045708.ru9COLib4d@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52639 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933149Ab3HNWrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 18:47:46 -0400
Content-Disposition: inline
In-Reply-To: <2045708.ru9COLib4d@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> Checklist:
> 1. super large regs->len: won't be greater than R8169_REGS_SIZE (256)
> 2. regs->len == 0: 0 < 0 is false, nothing is copied
> 3. regs->len is 1, 2 or 3: i = 0, at most 3 bytes will be copied
> 4. regs->len is 4, i < 4 - 4, skip loop, 0 < regs->len, copy 4
> 5. regs->len is 5, i < 5 - 4, copy; 4 < regs->len, copy 1

Spartan implementation:

	u32 __iomem *ioaddr = tp->mmio_addr;
	u32 *dw = p;
	int i;

	...

	for (i = regs->len; i > 0; i -= 4)
		memcpy_fromio(dw++, ioaddr++, min(i, 4));

or (min() verges on gluttony):

	for (i = regs->len; i >= 4; i -= 4)
		memcpy_fromio(dw++, ioaddr++, 4);

	if (i > 0)
		memcpy_fromio(dw, ioaddr, i);

-- 
Ueimor
