From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Thu, 22 Jul 2010 10:26:37 -0700 (PDT)
Message-ID: <20100722.102637.201684445.davem@davemloft.net>
References: <20100721.220611.267376790.davem@davemloft.net>
	<201007222146.FGC09386.OFOtFQOVFMJSLH@I-love.SAKURA.ne.jp>
	<20100722.102251.165153819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35321
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759162Ab0GVR0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 13:26:21 -0400
In-Reply-To: <20100722.102251.165153819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 22 Jul 2010 10:22:51 -0700 (PDT)

> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 22 Jul 2010 21:46:55 +0900
> 
>> David Miller wrote:
>>> > Then, why does below proposal lose information?
>>> 
>>> Peek changes state, now it's possible that two processes end up
>>> receiving the packet.
>> 
>> Indeed. We will need to protect sock->ops->recvmsg() call using a lock like
> 
> But this doesn't matter.

Also, btw, we're not adding a lock to a code path which we've worked
so hard to make largely lockless.  This lock is going to kill
performance.
