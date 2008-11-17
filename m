From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] softirq: Use local_irq_save() in local_bh_enable()
Date: Mon, 17 Nov 2008 17:16:17 +0100
Message-ID: <20081117161617.GF12081@elte.hu>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu> <20081117133548.GC6345@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:33779 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbYKQQQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 11:16:31 -0500
Content-Disposition: inline
In-Reply-To: <20081117133548.GC6345@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jarek Poplawski <jarkao2@gmail.com> wrote:

> This report: http://marc.info/?l=linux-netdev&m=122599341430090&w=2 
> shows local_bh_enable() is used in the wrong context (irqs 
> disabled). It happens when a usual network receive path is called by 
> netconsole, which simply turns off irqs around this all. Probably 
> this is wrong, but it worked like this long time, and it's not 
> trivial to fix this.
> 
> Anyway, a commit 0f476b6d91a1395bda6464e653ce66ea9bea7167 "softirq: 
> remove irqs_disabled warning from local_bh_enable" can break things 
> after changing from local_irq_save() to local_irq_disable(). Before 
> this commit there was only a warning, now a lockup is possible, so 
> it could be treated as a regression. This patch reverts the change 
> in irqs.

hm, but calling local_bh_enable() with hardirqs off is a bug. It might 
be a long-standing bug, but it can cause lockups even with that change 
reverted: when we process softirqs in local_bh_enable(). So why not 
fix the bug instead?

	Ingo
