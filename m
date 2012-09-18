From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: HTB vs CoDel performance
Date: Tue, 18 Sep 2012 17:56:57 +0800
Message-ID: <CAF1ivSYweQgxbCd_ejHmDi5w7puRkE7MbpV_hczhXXDca5DJ7A@mail.gmail.com>
References: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com>
	<1347961511.26523.216.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: networking <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:40867 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab2IRJ5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 05:57:36 -0400
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id F13A8DBBFC
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 17:56:59 +0800 (CST)
Received: by lbbgj3 with SMTP id gj3so4826205lbb.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 02:56:57 -0700 (PDT)
In-Reply-To: <1347961511.26523.216.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 18, 2012 at 5:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-09-18 at 17:28 +0800, Lin Ming wrote:
>> Hi,
>>
>> I'm testing htb performance on a gigabit router running 2.6.32 kernel.
>> Packet path: PC1 ---> Router LAN port ---> Router WAN port ---> PC2
>>
>> pfifo_fast: 920Mbps
>> htb: 750Mbps, ~20% drops compared to pfifo_fast
>>
>> htb tc commands as below,
>> # tc qdisc add dev eth10 root handle 20: htb default 1
>> # tc class add dev eth10 parent 20 classid 20:1 htb prio 2 rate
>> 1024Mbit ceil 1024Mbit burst 1281408b cburst 1281408b
>>
>> The performance drop seems caused by the complex htb enqueue/dequeue algorithm.
>>
>> I had a quick look at CoDel code, seems it does not have so complex
>> data structure as HTB.
>> I'm going to backport CoDel. Is this a good choice?
>> Can I gain similar performance as pfifo_fast?
>
> codel is quite different than HTB : It has no rate control, so its very
> fast. (But it has no prio differentiation as pfifo_fast with its 3
> bands)
>
> So what are your exact needs ?

I need traffic priority/traffic shaping/rate control ... actually all
QoS features on the router.
And if I just set the rate to gigabit(no other settings), for example,

# tc qdisc add dev eth10 root handle 20: htb default 1
# tc class add dev eth10 parent 20 classid 20:1 htb prio 2 rate
1024Mbit ceil 1024Mbit burst 1281408b cburst 1281408b

it should gain similar performance as pfifo_fast.

codel has no rate control. So seems I have to find way to optimize htb?
