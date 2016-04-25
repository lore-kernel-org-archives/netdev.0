From: Craig Gallek <kraig@google.com>
Subject: Re: net merged into net-next
Date: Mon, 25 Apr 2016 10:38:39 -0400
Message-ID: <CAEfhGiy9fvVKoN8henw2LtkhZHH0TjcXqsQHwy0OXmrM+Km9QA@mail.gmail.com>
References: <20160423.201230.364025148300253838.davem@davemloft.net>
	<1461461998.7627.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:35749 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbcDYOiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 10:38:51 -0400
Received: by mail-lb0-f179.google.com with SMTP id os9so79137192lbb.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 07:38:46 -0700 (PDT)
In-Reply-To: <1461461998.7627.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David,
There was one other change that conflicts (functionally) with this
merge as well: 3b24d854cb35 ("tcp/dccp: do not touch listener
sk_refcnt under synflood")
It did a similar hlist_nulls -> hlist transform for the TCP stack.
I'll send a formal patch to address this as well.

Craig

On Sat, Apr 23, 2016 at 9:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-04-23 at 20:12 -0400, David Miller wrote:
>> Eric, please double check my merge work for net/ipv4/udp.c
>>
>> In net we fixed a soreuseport bug that added a hlist_nulls_add_tail_rcu()
>> call to net/ipv4/udp.c
>>
>> And in net-next you converted UDP sockets away from nulls lists.
>>
>> Therefore I had to add a hlist_add_tail_rcu() implementation to
>> linux/rculist.h and use it in net/ipv4/udp.c
>>
>> Please make sure this is fine and will work safely.
>>
>> Thanks!
>
> Looks fine to me, thanks David
>
> Craig, please have a look ?
>
> ( commit 1602f49b58abcb0d34a5f0a29d68e7c1769547aa in net-next)
>
>
