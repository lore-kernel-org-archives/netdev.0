From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
Date: Sun, 30 Aug 2009 09:47:05 +0200
Message-ID: <4A9A2E79.5030808@gmail.com>
References: <20090830062344.6380.16713.sendpatchset@localhost.localdomain> <4A9A223D.1060406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krishna Kumar <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:53332 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752666AbZH3HrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 03:47:12 -0400
Received: by fxm17 with SMTP id 17so2245463fxm.37
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 00:47:12 -0700 (PDT)
In-Reply-To: <4A9A223D.1060406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 08/30/2009 08:54 AM:

> Krishna Kumar a =E9crit :
>> From: Krishna Kumar <krkumar2@in.ibm.com>
>>
>> pfifo_fast_enqueue has this check:
>>         if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
>>
>> which allows each band to enqueue upto tx_queue_len skbs for a
>> total of 3*tx_queue_len skbs. I am not sure if this was the
>> intention of limiting in qdisc.
>=20
> Yes I noticed that and said to myself :
> This was to let high priority packets have their own limit,
> independent on fact that low priority packets filled their queue.


Good point, but then logically it could be something like:
  if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len / 3)

Of course, there is a backward compatibility question, plus
an sch_prio consistency question.

Jarek P.
