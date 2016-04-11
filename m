From: Lars Persson <lars.persson@axis.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 17:17:56 +0200
Message-ID: <570BC024.1070504@axis.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>	 <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>	 <570BA8C7.1000905@axis.com> <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jhs@mojatatu.com>,
	<linux-kernel@vger.kernel.org>, <xiyou.wangcong@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Lars Persson <larper@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:46095 "EHLO
	bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbcDKPSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 11:18:00 -0400
In-Reply-To: <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/11/2016 04:22 PM, Eric Dumazet wrote:
> On Mon, 2016-04-11 at 15:38 +0200, Lars Persson wrote:
>
>> I though it would be prudent because the queue can be non-empty even for
>> the case of skb=NULL. So should it be there in this patch, another patch
>> or not at all ?
>
> Then maybe change return code ?
>
> It seems strange that a validate_xmit_skb_list() failure stops the
> __qdisc_run() loop but schedules another round.
>
>

It was suggested by Cong Wang to return 0 in order to stop the loop. Do 
you guys agree that the loop should be stopped for such failures ? Then 
I will put the schedule call inside the if as you proposed earlier.

- Lars
