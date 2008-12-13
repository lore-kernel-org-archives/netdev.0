From: Kalle Valo <kalle.valo@nokia.com>
Subject: Re: [Patch] Micrel KS8695 intergrated ethernet driver
Date: Sat, 13 Dec 2008 21:07:25 +0200
Message-ID: <8763lnnbbm.fsf@nokia.com>
References: <49394379.9000501@simtec.co.uk>
	<1228499870.3520.66.camel@achroite>
	<1228734318.19000.84.camel@petitemort>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: dsilvers@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:34458 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbYLMTIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:08:09 -0500
In-Reply-To: <1228734318.19000.84.camel@petitemort> (ext Daniel Silverstone's message of "Mon\, 08 Dec 2008 11\:05\:18 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Silverstone <dsilvers@simtec.co.uk> writes:

>> > +       if (ksp->tx_buffers[buff_n].skb) {
>> > +               /* This slot is used, try later */
>> > +               spin_unlock_irq(&ksp->txq_lock);
>> > +               return -EAGAIN;
>> Since you already tested tx_ring_used, wouldn't this indicate a bug?
>
> Yep, this was old code before I kept a track in tx_ring_used. Changed
> to:
>
> BUG_ON(ksp->tx_buffers[buff_n].skb);

I would say that a network driver should never use BUG_ON(), it just
makes both user's and developer's life difficult because the whole
kernel will stop the execution. WARN_ON() is much nicer, it just
prints a nice warning to the log which then can be reported either
manually or automatically.

-- 
Kalle Valo
