From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: Fix statistics locking scheme
Date: Fri, 13 Mar 2015 20:05:36 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63C10E0E@avmb3.qlogic.org>
References: <1426253565-10302-1-git-send-email-Yuval.Mintz@qlogic.com>
	<20150313.123822.1761706097366192562.davem@davemloft.net>
	<B5657A6538887040AD3A81F1008BEC63C10D9E@avmb3.qlogic.org>,<20150313.155147.274140101234642831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avcashub3.qlogic.com ([198.70.193.117]:31238 "EHLO
	avcashub1.qlogic.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754137AbbCMUFi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 16:05:38 -0400
In-Reply-To: <20150313.155147.274140101234642831.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I've no real objection to re-spinning this,
>> given that it's an error flow we've never actually encountered.
>> Do notice that this doesn't change existing behavior of code.

>I disagree.

>The existing code took the spinlock unconditionally, and only
>executed the critical section under the lock.

>This exact place is where you are adding the semaphore timeout
>stuff I am specifically objecting too.

I can't really see why we should look at the existing spinlock critical
section as if that's the more important one, given that the surrounding
logic is broken, i.e., that a context switch between the spinlock release
and the action() taking place might result in the state machine no
longer truthfully representing the actual HW/FW configuration.

Regardless, you've made your disdain for this... well, more than obvious.
And since I can't really justify this behaviour, I think I'll simply re-spin it. 
