From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Thu, 15 Aug 2013 22:33:15 +0200
Message-ID: <1376598795.11042.1.camel@deadeye.wl.decadent.org.uk>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com>
	 <3465288.NFVErF5E7l@al> <20130814195829.GA1613@electric-eye.fr.zoreil.com>
	 <2045708.ru9COLib4d@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8891 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674Ab3HOUdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 16:33:22 -0400
In-Reply-To: <2045708.ru9COLib4d@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-14 at 23:31 +0200, Peter Wu wrote:
> On Wednesday 14 August 2013 21:58:29 Francois Romieu wrote:
> > > -     memcpy_fromio(p, tp->mmio_addr, regs->len);
> > > +     if (regs->len >= 4) {
> > > +             for (i = 0; i < regs->len - 4; i += 4)
> > > +                     memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
> > > +     }
> > > +     if (i < regs->len)
> > 
> > Comparison with random stack stuff when regs->len < 4. :o/
> 
> Right, let's rm $OLD_PATCH and consider this one.
> 
> Checklist:
> 1. super large regs->len: won't be greater than R8169_REGS_SIZE (256)
> 2. regs->len == 0: 0 < 0 is false, nothing is copied
> 3. regs->len is 1, 2 or 3: i = 0, at most 3 bytes will be copied
> 4. regs->len is 4, i < 4 - 4, skip loop, 0 < regs->len, copy 4
> 5. regs->len is 5, i < 5 - 4, copy; 4 < regs->len, copy 1
[...]

The kernel buffer size is max(regs->len,
dev->ethtool_ops->get_regs_len()).  So you can safely ignore regs->len
and always read all your registers.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
