From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] qdisc: validate skb without holding lock
Date: Fri, 03 Oct 2014 16:30:44 -0700
Message-ID: <1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.153645.72976986956341944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:60778 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755561AbaJCXaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 19:30:13 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2244036pab.16
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 16:30:12 -0700 (PDT)
In-Reply-To: <20141003.153645.72976986956341944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-03 at 15:36 -0700, David Miller wrote:

> Applied, thanks Eric!

Thanks David

Another problem we need to address is the quota in __qdisc_run()
is no longer meaningfull, if each qdisc_restart() can pump many packets.

An idea would be to use the bstats (or cpu_qstats if applicable)
