From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc
 to inappropriate ones
Date: Thu, 27 Aug 2015 15:42:02 -0700 (PDT)
Message-ID: <20150827.154202.1831965840563413727.davem@davemloft.net>
References: <1440628887-3504-5-git-send-email-xiyou.wangcong@gmail.com>
	<20150827.153046.2021133935222197667.davem@davemloft.net>
	<CAM_iQpX4VFeEe4zGj0kx7x7q6GO7Kx+kKC2FW_CRiGSrk0aZVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178AbbH0WmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 18:42:03 -0400
In-Reply-To: <CAM_iQpX4VFeEe4zGj0kx7x7q6GO7Kx+kKC2FW_CRiGSrk0aZVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 27 Aug 2015 15:39:12 -0700

> On Thu, Aug 27, 2015 at 3:30 PM, David Miller <davem@davemloft.net> wrote:
>> I don't like this.
>>
>> The situation is that some sophisticated qdiscs can function without
>> explicit parameters, some cannot.
> 
> This is exactly what this patch tries to solve... I already mark those
> with a DEFAULTABLE flag.

It is not solving it, if you were solving it you would make all qdisc's
capable of being default instead of giving them what is essentially
"this is broken" flag.
> I wish I never mention that crash, which leads you to think I am trying
> to fix a crash rather than a more important issue, usability. See below.
> 
> Forget about the crash, consider the current behavior:
> 
> # echo htb > default_qdisc
> # succeed without any error
> (then add a root qdisc and remove it)
> # failure shown here in dmesg
> 
> And compare it with the behavior after my patch:
> 
> # echo htb > default_qdisc
> Invalid arguments
> 
> I think this is clearly an improvement.

Long term it's the wrong fix, trust me.

If you fix it properly, by making every qdisc capable of being ->init()'d
without explicit parameters, it will be the best behavior overall.
