From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: net_sched: dsmark: use qdisc_dequeue_peeked()
Date: Wed, 2 Mar 2016 17:56:02 +0300
Message-ID: <56D6FF02.7060003@cogentembedded.com>
References: <1456891804.3297.51.camel@kyeongy-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33043 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbcCBO4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 09:56:06 -0500
Received: by mail-lb0-f172.google.com with SMTP id k15so8676072lbg.0
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 06:56:05 -0800 (PST)
In-Reply-To: <1456891804.3297.51.camel@kyeongy-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/2/2016 7:10 AM, Kyeong Yoo wrote:

> This fix is for dsmark similar to 3557619f0f6f7496ed453d4825e24958ab1884e0,

    scripts/checkpatch.pl now enforces certain commit citing format, yours 
doesn't match it.

> and makes use of qdisc_dequeue_peeked() instead of direct dequeue() call.
>
> First time, wrr peeks dsmark, which will then peek into sfq.
> sfq dequeues an skb and it's stored in sch->gso_skb.
> Next time, wrr tries to dequeue from dsmark, which will call sfq dequeue
> directly. This results skipping the previously peeked skb.
>
> So changed dsmark dequeue to call qdisc_dequeue_peeked() instead to use
> peeked skb if exists.
>
> Also replaced dsmark peek to use qdisc_peek_dequeued() which works correctly
> if previously peeked skb still exists.
>
> Signed-off-by: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>

[...]

MBR, Sergei
