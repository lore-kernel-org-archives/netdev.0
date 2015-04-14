From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: Fix netpoll interoperability
Date: Tue, 14 Apr 2015 16:44:22 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63CF5830@AVMB1.qlogic.org>
References: <1429018513-9553-1-git-send-email-Yuval.Mintz@qlogic.com>,<1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:48951 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932975AbbDNQom convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 12:44:42 -0400
In-Reply-To: <1429023140.7346.33.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Commit 9a2620c877454 ("bnx2x: prevent WARN during driver unload") switched
>> the napi/busy_lock locking mechanism from spin_lock() into spin_lock_bh(),
>> breaking inter-operability with netconsole, as netpoll disables interrupts
>> prior to calling our napi mechanism.
>>
>> This switches the driver into using atomic assignments instead of the spinlock
>> mechanisms previously employed.

> This fix is prone to starvation of softirq handler.
> Since you use 2 bits, I believe you could set one bit unconditionally to
> make sure the bnx2x_low_latency_recv() will yield to softirq handler.

Care to elaborate a bit? About the possibly starvation?

> Please CC me and Willem on busypoll stuff, thanks !

Sure.
