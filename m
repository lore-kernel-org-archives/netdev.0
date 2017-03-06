From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: sched: make default fifo qdiscs appear in the
 dump
Date: Mon, 06 Mar 2017 10:35:55 -0800 (PST)
Message-ID: <20170306.103555.1351381782582641603.davem@davemloft.net>
References: <alpine.LSU.2.20.1702252226530.24579@cbobk.fhfr.pm>
        <20170301.132144.1380602514921591101.davem@davemloft.net>
        <alpine.LSU.2.20.1703061158500.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
        jhs@mojatatu.com, phil@nwl.cc, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: jikos@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753532AbdCFSgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 13:36:19 -0500
In-Reply-To: <alpine.LSU.2.20.1703061158500.31814@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jikos@kernel.org>
Date: Mon, 6 Mar 2017 12:03:38 +0100 (CET)

> Ah, right you are, thanks. The complete fix is not super trivial, as it 
> needs some more surgery to tc_dump_qdisc_root(), tc_dump_tclass_root() and 
> qdisc_match_from_root() (see 69012ae42 for some details).
> 
> There are two options:
> 
> - this gets fixed in two phases, in first everything *but* noop qdisc gets 
>   dumped (in the "give me everything" dump) and later we finalize it by
>   teaching the above functions about noop_qdisc as well
> 
> - I extend this patchset to handle noop qdisc from the very beginning; 
>   I am unlikely to find time for this during coming weeks though. But OTOH
>   this whole thing is very low priority anyway
> 
> What do you think?

I'm not too hot on this whole idea because the only way you can emit
the noop_qdisc is to "dup" it by allocating a new qdisc so that you
can link it in.  This has two downsides:

1) Extra overhead and memory usage

2) All of the simple checks against &noop_qdisc might not be
   so simply any more.
