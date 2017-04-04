From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: minimize false-positives on TCP/GRO check
Date: Mon, 03 Apr 2017 18:44:56 -0700 (PDT)
Message-ID: <20170403.184456.724166144761742945.davem@davemloft.net>
References: <47c94077ffa8988118a19514389b42fccdc2f6ef.1491054871.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        jmaxwell37@gmail.com, markus@trippelsdorf.de
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdDDBpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 21:45:00 -0400
In-Reply-To: <47c94077ffa8988118a19514389b42fccdc2f6ef.1491054871.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Sat,  1 Apr 2017 11:00:21 -0300

> Markus Trippelsdorf reported that after commit dcb17d22e1c2 ("tcp: warn
> on bogus MSS and try to amend it") the kernel started logging the
> warning for a NIC driver that doesn't even support GRO.
> 
> It was diagnosed that it was possibly caused on connections that were
> using TCP Timestamps but some packets lacked the Timestamps option. As
> we reduce rcv_mss when timestamps are used, the lack of them would cause
> the packets to be bigger than expected, although this is a valid case.
> 
> As this warning is more as a hint, getting a clean-cut on the
> threshold is probably not worth the execution time spent on it. This
> patch thus alleviates the false-positives with 2 quick checks: by
> accounting for the entire TCP option space and also checking against the
> interface MTU if it's available.
> 
> These changes, specially the MTU one, might mask some real positives,
> though if they are really happening, it's possible that sooner or later
> it will be triggered anyway.
> 
> Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks Marcelo.
