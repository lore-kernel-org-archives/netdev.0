From: Vasily Averin <vvs@parallels.com>
Subject: Re: [PATCH 1/2] cbq: incorrectly low bandwidth setting blocks limited
 traffic
Date: Wed, 13 Aug 2014 16:54:22 +0400
Message-ID: <53EB5FFE.1070604@parallels.com>
References: <cover.1407918877.git.vvs@openvz.org> <53EB5C3A.1040206@parallels.com> <53EB5DE8.7030302@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31315 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbaHMM4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 08:56:06 -0400
In-Reply-To: <53EB5DE8.7030302@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2014 04:45 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 8/13/2014 4:38 PM, Vasily Averin wrote:
> 
>> Mainstream commit f0f6ee1f70c4eaab9d52cf7d255df4bd89f8d1c2 have side effect:
> 
>    Please also specify that commit's summary line in parens.
cbq: incorrect processing of high limits

>> if cbq bandwidth setting is less than real interface throughput
>> non-limited traffic can delay limited traffic for a very long time.
> 
>> This happen because of q->now changes incorrectly in cbq_dequeue():
>> in described scenario L2T is much greater than real time delay,
>> and q->now gets an extra boost for each transmitted packet.
> 
>> Accumulated boost prevents update q->now, and blocked class can wait
>> very long time until (q->now >= cl->undertime) will be true again.
> 
>> To fix the problem the patch updates q->now on each cbq_update() call.
>> L2T-related pre-modification q->now was moved to cbq_update().
> 
>> My testing confirmed that it fixes the problem and did not discovered
> 
>   Discover.
> 
>> any side-effects.
> 
>> Signed-off-by: Vasily Averin <vvs@openvz.org>
> 
> WBR, Sergei
> 
> 
