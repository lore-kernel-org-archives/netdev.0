From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 4/4] bonding: Fix some RTNL taking
Date: Thu, 17 Jan 2008 14:30:37 +0900
Message-ID: <478EE7FD.3010802@miraclelinux.com>
References: <20080116124450.GD2307@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:30831 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbYAQFc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 00:32:29 -0500
In-Reply-To: <20080116124450.GD2307@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Maybe I'm wrong, but since this read_lock() is given and taken anyway,
> it seems this looks a bit better to me (why hold this rtnl longer
> than needed?):
> 		read_unlock(&bond->lock);
> 		rtnl_unlock();
> 		read_lock(&bond->lock);
Seems better.

> On the other hand, probably 'if (bond->kill_timers)' could be repeated
> after this read_lock() retaking.
Sorry, what do you mean? (A case that bond->kill_timers = 1 is done during 
lock retaking, and work being queued only to do 'if (bond->kill_timers)'? If 
so, I think that won't differ much.)

> If this if () is really necessary here, then this should be better
> before "delay = ..." with a block.
I agree.

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION
