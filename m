From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sch_htb: add HTB_LEAF_LIMIT attribute
Date: Fri, 06 Dec 2013 05:48:52 -0800
Message-ID: <1386337732.30495.260.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386322324-87976-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:47000 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161749Ab3LFNsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 08:48:55 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so1089846pbb.23
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 05:48:55 -0800 (PST)
In-Reply-To: <1386322324-87976-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-06 at 17:32 +0800, Yang Yingliang wrote:
> HTB uses an internal pfifo queue, which limit is inherited from
> device tx_queue_len. But virtual device's tx_queue_len is 0, so
> the limit will be initialized to 1.
> 
> Introduce TCA_HTB_LEAF_LIMIT attribute to allow finer control.

Most users overcome this by explicitly attach pfifo or whatever qdisc
they want on the htb class.

As a bonus, this qdisc is visible and we can get a rate estimator, and
all the stats.

And if somebody attaches a HTB qdisc to a virtual device, he also
changes txqueuelen before doing so.

Anyway, I was working on being able to attach fq instead of pifo, with
a variant of fq sharing the hash table.

I cannot really understand how people can still use pfifo on htb classes
nowadays.
