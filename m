From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 14:37:12 -0400 (EDT)
Message-ID: <20140318.143712.1925745769166753460.davem@davemloft.net>
References: <87fvmgf2c7.fsf_-_@xmission.com>
	<20140318082358.60fc414c@nehalam.linuxnetplumber.net>
	<8738if8klj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756673AbaCRShP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:37:15 -0400
In-Reply-To: <8738if8klj.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 18 Mar 2014 10:47:36 -0700

> Most of the destructors today are fine (which doubly makes the warning
> confusing).

Not true by my estimation.  We absolutely do not want socket state being
modified from hardware interrupts, and that's the most common destructor,
releasing socket memory.
