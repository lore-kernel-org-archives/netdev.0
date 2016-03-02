From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net_sched: dsmark: use qdisc_dequeue_peeked()
Date: Wed, 2 Mar 2016 10:26:27 -0800
Message-ID: <CAM_iQpWGtRfbbGKD6i+XY0epgNkn=mNGnWG31dLhq7XLykdvFQ@mail.gmail.com>
References: <1456891804.3297.51.camel@kyeongy-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:36832 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264AbcCBS02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:26:28 -0500
Received: by mail-yw0-f179.google.com with SMTP id e63so183699263ywc.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 10:26:28 -0800 (PST)
In-Reply-To: <1456891804.3297.51.camel@kyeongy-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 8:10 PM, Kyeong Yoo
<Kyeong.Yoo@alliedtelesis.co.nz> wrote:
> This fix is for dsmark similar to 3557619f0f6f7496ed453d4825e24958ab1884e0,
> and makes use of qdisc_dequeue_peeked() instead of direct dequeue() call.
>
> First time, wrr peeks dsmark, which will then peek into sfq.
> sfq dequeues an skb and it's stored in sch->gso_skb.
> Next time, wrr tries to dequeue from dsmark, which will call sfq dequeue
> directly. This results skipping the previously peeked skb.
>
> So changed dsmark dequeue to call qdisc_dequeue_peeked() instead to use
> peeked skb if exists.


This part looks reasonable to me.

>
> Also replaced dsmark peek to use qdisc_peek_dequeued() which works correctly
> if previously peeked skb still exists.


But not this part, since sfq already calls qdisc_peek_dequeued()?
