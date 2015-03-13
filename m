From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: Fix statistics locking scheme
Date: Fri, 13 Mar 2015 19:02:36 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63C10D9E@avmb3.qlogic.org>
References: <1426253565-10302-1-git-send-email-Yuval.Mintz@qlogic.com>,<20150313.123822.1761706097366192562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avcashub3.qlogic.com ([198.70.193.117]:13629 "EHLO
	avcashub1.qlogic.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754295AbbCMTCi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:02:38 -0400
In-Reply-To: <20150313.123822.1761706097366192562.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is terrible.

> Either you use locking to protect critical sections, or you don't.

> I do not want to see any code that enters the critical
> section when the locked state cannot be acquired.

I've no real objection to re-spinning this, 
given that it's an error flow we've never actually encountered.

Do notice that this doesn't change existing behavior of code.
I.e., existing code doesn't exit on failure to lock.