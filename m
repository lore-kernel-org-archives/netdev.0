From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: add cond_resched() to class and
 qdisc dump
Date: Mon, 10 Mar 2014 13:12:24 -0700
Message-ID: <1394482344.3607.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394244064.20149.51.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140310.153205.851677230247140352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:35944 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258AbaCJUM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:12:26 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so7691064pbb.19
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 13:12:25 -0700 (PDT)
In-Reply-To: <20140310.153205.851677230247140352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 15:32 -0400, David Miller wrote:

> Is it OK to sleep (or rather: cond_resched()) in an RCU region?
> That's what will potentially happen via tc_dump_qdisc() it seems.

Hmpf, you are right I forgot this.

RTNL protects us in tc_dump_qdisc().

I need to remove this useless rcu protection.

Thanks
