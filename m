From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: Fix netpoll interoperability
Date: Tue, 14 Apr 2015 18:11:47 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63CF58CE@AVMB1.qlogic.org>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>
	 ,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>,<1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, "bind@enas.net" <bind@enas.net>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"Willem de Bruijn" <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56801 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753993AbbDNSMK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 14:12:10 -0400
In-Reply-To: <1429033912.7346.47.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I believe the original busypoll yield concern was forgotten or reversed.

> If you have many busypoll users, they might get the 'lock', and the poor
> cpu that received the hardware interrupt and raised RX softirq for this
> RX queue will spin forever [1]

> busypoll users should backoff and not attempt to grab a lock (especially
> if this lock is not a ticket lock anymore) if the softirq handler is
> desperately trying to make progress.

> [1]
> sofirq handler

>   while (1) {
>       if (!bnx2x_fp_lock_napi())
>                continue;

bnx2x returns the budget, it doesn't loop in the poll function.
[I don't have the napi_poll logic in mind, but I do hope it doesn't iterate
repeatedly but rather only on next re-schedule]

>        }
>   }

> I can provide an alternative patch if you like.

If you're willing to make the effort, sure.
