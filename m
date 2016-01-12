From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v2] net, sched: add clsact qdisc
Date: Tue, 12 Jan 2016 09:15:18 -0800
Message-ID: <569534A6.9070505@gmail.com>
References: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net> <5694F6F0.3020205@mojatatu.com> <569511B6.8010306@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36367 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbcALRPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 12:15:32 -0500
Received: by mail-pa0-f68.google.com with SMTP id a20so20928600pag.3
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 09:15:31 -0800 (PST)
In-Reply-To: <569511B6.8010306@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> Just the leftover default setup for egress, nothing more.
> 
>>>     qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1
>>> 1 1 1 1 1 1 1
>>>     qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1
>>> 1 1 1 1 1 1 1
>>>     qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1
>>> 1 1 1 1 1 1 1
>>>     qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1
>>> 1 1 1 1 1 1 1
>>>     qdisc clsact ffff: parent ffff:fff1
>>
>> Is there any reason this is not just tc qdisc add dev foo ingress ?
>> I doubt things will break..
> 
> Actually I already tried to explain that in the commit message, since
> one can
> use any possible minor with ingress qdisc, I would like to have a hard
> guarantee
> that setups suddenly don't break and unexpected things happen even if
> likelihood
> is rather small (but not zero). The option would have been to add a
> 'mode' setting
> over netlink on initialization for ingress and deal with the details in
> each callback
> based on the mode (plus aliasing ingress qdisc to something generic,
> otherwise why
> adding ingress qdisc to add filters to egress? ;)). Eventually, it was
> more straight
> forward and cleaner, imho, to just have their own handlers where they
> both differ.
> 

FWIW I asked Daniel the same question on an earlier version and came
to the same conclusion it really is much cleaner to handle it the way
he did in this patch.

Thanks,
John
