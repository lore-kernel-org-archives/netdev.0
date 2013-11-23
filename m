From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: tbf: fix an oops when a GSO packet cannot
 be enqueued
Date: Sat, 23 Nov 2013 09:56:07 -0800
Message-ID: <1385229367.10637.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385112446-15564-1-git-send-email-yangyingliang@huawei.com>
	 <1385131801.10637.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5290628F.6080604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ben@decadent.org.uk,
	jpirko@redhat.com, jhs@mojatatu.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:51031 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab3KWR4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 12:56:09 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so2909163pde.14
        for <netdev@vger.kernel.org>; Sat, 23 Nov 2013 09:56:08 -0800 (PST)
In-Reply-To: <5290628F.6080604@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-23 at 16:08 +0800, Yang Yingliang wrote:

> 
> I've applied this patch, but it's oops too.
> I think it's not the same problem. In this
> problem, when the segs is not enqueued, we do
> nothing to the segs.I think it causes the
> problem. If I am wrong, please point out.
> Thanks!
> 
> Here is the call trace after applying the above patch:
> BTW, the call trace is not always same no matter the
> above patch is applied.
> 

Oh right. Your patch on the right way, but changelog very confusing.

BTW, setting a mtu of 1KB on TBF never worked if your ethernet device
has MTU of 1500.

I think that we should emit a warning if TBF mtu is too low.

Ideally we should not even call skb_gso_segment() at all.

I'll post an updated version of the patch with a more detailed changelog
and explanations.

Thanks !
