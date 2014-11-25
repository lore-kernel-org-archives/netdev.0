From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] sch_fq: segment too big GSO packets
Date: Tue, 25 Nov 2014 08:31:34 -0800
Message-ID: <1416933094.29427.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:47666 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaKYQbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:31:41 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so875724ieb.3
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:31:40 -0800 (PST)
In-Reply-To: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-25 at 21:24 +0800, Yang Yingliang wrote:
> As the TODO says: "maybe segment the too big skb, as in commit
> e43ac79a4bc ("sch_tbf: segment too big GSO packets")" in fq_dequeue(),
> this patchset segment the GSO packets that are too big.
> 
> Sometimes a GSO packet is too big at a low rate. This patchset check
> the packet before it's enqueued, if the GSO packet cost more than 125ms
> to send, it will be segmented, then enqueue the segments one by one.
> Because of the segment, the qlen may be bigger than limit in some condition.
> My way is that let the packet in if qlen is smaller than limit before
> it's segmented.

We extended the 125ms value to 750ms, back in July.

I will upstream this change, now it gave us good experimental results.

There is no point segmenting packets with 2 MSS, as fq quantum is 2 MSS
by default.

Your patches are the wrong way to handle this.

We have SO_MAX_PACING_RATE, and try to cook GSO packets of the right
size, instead of segmenting them later.
