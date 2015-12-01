From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: size overflow in function qdisc_tree_decrease_qlen
 net/sched/sch_api.c
Date: Tue, 01 Dec 2015 11:09:24 -0800
Message-ID: <1448996964.16994.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151201010005.GA23175@Fux-PC>
	 <1448978807.25582.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448979011.25582.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <565DC716.22673.2DBA261B@pageexec.freemail.hu>
	 <1448987660.2977.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7NiYjhE5dY7HPkWuoTA5WMqF3zPyCFk5i3LYTUrYD7gYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pageexec@freemail.hu, Daniele Fucini <dfucini@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, spender@grsecurity.net,
	re.emese@gmail.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35421 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbbLATJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 14:09:26 -0500
Received: by pacej9 with SMTP id ej9so13826561pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 11:09:26 -0800 (PST)
In-Reply-To: <CAHA+R7NiYjhE5dY7HPkWuoTA5WMqF3zPyCFk5i3LYTUrYD7gYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-01 at 10:43 -0800, Cong Wang wrote:

> This smells hacky... Another way to fix this is to hold the qdisc tree
> lock in mq_dump(), since it is not a hot path (comparing with
> enqueue/dequeue)?

Really ? Which qdisc tree lock will protect you exactly ???

Whole point of MQ is that each TX queue has its own lock.

So multiple cpus can call qdisc_tree_decrease_qlen() at the same time,
holding their own lock.

Clearly modifying mq 'data' is wrong.
