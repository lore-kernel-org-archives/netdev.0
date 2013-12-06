From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v5 2/2] net: sched: htb: fix calculation of quantum
Date: Fri, 6 Dec 2013 10:36:26 +0800
Message-ID: <52A1382A.6030504@huawei.com>
References: <1386227457-86900-1-git-send-email-yangyingliang@huawei.com>	 <1386227457-86900-3-git-send-email-yangyingliang@huawei.com> <1386245932.30495.169.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2551 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab3LFCg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 21:36:58 -0500
In-Reply-To: <1386245932.30495.169.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/5 20:18, Eric Dumazet wrote:
> On Thu, 2013-12-05 at 15:10 +0800, Yang Yingliang wrote:
>>  	if (!cl->level) {
>> -		cl->quantum = hopt->rate.rate / q->rate2quantum;
>> +		u64 quantum = div64_u64(cl->rate.rate_bytes_ps,
>> +					q->rate2quantum);
> 
> 		q->rate2quantum being 32bit, prefer the following :
> 
> 		u64 quantum = cl->rate.rate_bytes_ps;
> 
> 		do_div(quantum, q->rate2quantum);
> 
> 		Since it maps to better assembly code on 32bit arches.

Change it in v6, thanks!

Regards,
Yang
