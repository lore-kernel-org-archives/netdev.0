From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: better validation of received ack
 sequences
Date: Thu, 25 May 2017 13:22:36 -0400 (EDT)
Message-ID: <20170525.132236.1835338699503607288.davem@davemloft.net>
References: <1495578286.6465.90.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170525.124817.1960721450872387047.davem@davemloft.net>
        <1495731051.6465.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p.fiterau-brostean@science.ru.nl, netdev@vger.kernel.org,
        F.Vaandrager@cs.ru.nl, ncardwell@google.com, ycheng@google.com,
        soheil@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933592AbdEYRWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:22:38 -0400
In-Reply-To: <1495731051.6465.100.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 25 May 2017 09:50:51 -0700

> On Thu, 2017-05-25 at 12:48 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 23 May 2017 15:24:46 -0700
>> 
>> > Add a FLAG_NO_CHALLENGE_ACK so that tcp_rcv_state_process()
>> > can choose to send a challenge ACK and discard the packet instead
>> > of wrongly change socket state.
>> 
>> Applied, but the tests end up being double-negatives so it might
>> have been easier to understand if the flag was a positive rather
>> than a negative value.
> 
> I thought of this (and was in fact one of the patch I sent for internal
> review at Google), but this was changing all tcp_ack() calls instead of
> a single one ?
> 
> Or maybe I am missing some easier way ?

Indeed, it is a bit of churn to adjust all callers in order to make
one test easier to read.

I'm not so sure it's better or worth it...
