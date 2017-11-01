From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix tcp_mtu_probe() vs highest_sack
Date: Wed, 01 Nov 2017 21:20:17 +0900 (KST)
Message-ID: <20171101.212017.1641618919081120898.davem@davemloft.net>
References: <CAK6E8=ddfOpvr9wqb+3bo+-pQm2XLXuLhGSQk6xk0Tb8-UvHeA@mail.gmail.com>
        <CANn89iKm6E6vJ6m81ULFZVoVO3B5-pshB0=wPdvYgbYS+Wg8eQ@mail.gmail.com>
        <1509430100.3828.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, alexei.starovoitov@gmail.com,
        oleksandr@natalenko.name, guro@fb.com, netdev@vger.kernel.org,
        ncardwell@google.com, brakmo@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932625AbdKAMUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 08:20:22 -0400
In-Reply-To: <1509430100.3828.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Oct 2017 23:08:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Based on SNMP values provided by Roman, Yuchung made the observation
> that some crashes in tcp_sacktag_walk() might be caused by MTU probing.
> 
> Looking at tcp_mtu_probe(), I found that when a new skb was placed
> in front of the write queue, we were not updating tcp highest sack.
> 
> If one skb is freed because all its content was copied to the new skb
> (for MTU probing), then tp->highest_sack could point to a now freed skb.
> 
> Bad things would then happen, including infinite loops.
> 
> This patch renames tcp_highest_sack_combine() and uses it
> from tcp_mtu_probe() to fix the bug.
> 
> Note that I also removed one test against tp->sacked_out,
> since we want to replace tp->highest_sack regardless of whatever
> condition, since keeping a stale pointer to freed skb is a recipe
> for disaster.
> 
> Fixes: a47e5a988a57 ("[TCP]: Convert highest_sack to sk_buff to allow direct access")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Reported-by: Roman Gushchin <guro@fb.com>
> Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>

Applied and queued up for -stable.
