From: David Miller <davem@davemloft.net>
Subject: Re: [kernel,2.6.33-git11] lib8390: use spin_lock_irqsave for
 locking
Date: Sun, 07 Mar 2010 15:22:30 -0800 (PST)
Message-ID: <20100307.152230.09914483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52999
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750832Ab0CGXWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:22:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This change is not correct.

disable_irq is being intentionally used because the reset
sequence can take a very long time and we don't want to
have cpu interrupts disabled during the entire sequence.

Otherwise slow serial devices will drop characters and
stuff like that.
