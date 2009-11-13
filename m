From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 07:45:08 +0000
Message-ID: <20091113074508.GA6605@ff.dom.local>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:57746 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbZKMHpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:45:10 -0500
Received: by bwz27 with SMTP id 27so3107881bwz.21
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 23:45:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-11-2009 07:16, Changli Gao wrote:
> 2009/11/13 Eric Dumazet <eric.dumazet@gmail.com>:
>> Messy ? Because of few tests added in code, and branches always
>> correctly predicted ?
>>
>> Still some people might rely on tasklet instead of workqueues
>> and added scheduler stress and latency penalty. Tasklet are softirq
>> and normally are processed a few nanosecs later than RX softirq,
>> on the same CPU, while with your workqueue, I guess the scheduler will
>> try to not migrate it, so we add a penalty for light to moderate load.
>>
>> I guess this new ifb mode would be a regression for them ?
>>
>> If you dont want to maintain a compatibility mode, maybe you
>> should introduce a complete new driver, drivers/net/ifbmq.c or ifbwq.c
>>
>> (multiqueue or workqueue references)
>>
> 
> It sounds a good idea.

I don't think so. There would be a lot of code duplication and later
maintenance problems only because of the scheduling method. The main
question is to establish if there is really no performance difference
(which I doubt) - unless Changli can show some tests for various
setups now. On the other hand, if there is a difference, why keep
ineffective solution - similar thing should be possible to do in the
softirq context as well.

So it should not be a big problem to do it a bit messy for some
testing time. Since we can use separate ->ndo_start_xmit() etc. it
shouldn't be too messy, I guess.

Jarek P.
