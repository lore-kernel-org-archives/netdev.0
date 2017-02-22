From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] tcp: setup timestamp offset when write_seq
 already set
Date: Wed, 22 Feb 2017 16:33:37 -0500 (EST)
Message-ID: <20170222.163337.1789197655018339564.davem@davemloft.net>
References: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, edumazet@google.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932293AbdBVVdj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 16:33:39 -0500
In-Reply-To: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Wed, 22 Feb 2017 13:23:55 +0300

> Found that when randomized tcp offsets are enabled (by default)
> TCP client can still start new connections without them. Later,
> if server does active close and re-uses sockets in TIME-WAIT
> state, new SYN from client can be rejected on PAWS check inside
> tcp_timewait_state_process(), because either tw_ts_recent or
> rcv_tsval doesn't really have an offset set.
> 
> Here is how to reproduce it with LTP netstress tool:
>     netstress -R 1 &
>     netstress -H 127.0.0.1 -lr 1000000 -a1
> 
>     [...]
>     < S  seq 1956977072 win 43690 TS val 295618 ecr 459956970
>     > .  ack 1956911535 win 342 TS val 459967184 ecr 1547117608
>     < R  seq 1956911535 win 0 length 0
> +1. < S  seq 1956977072 win 43690 TS val 296640 ecr 459956970
>     > S. seq 657450664 ack 1956977073 win 43690 TS val 459968205 ecr 296640
> 
> Fixes: 95a22caee396 ("tcp: randomize tcp timestamp offsets for each connection")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Applied.
