From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net sched actions: Complete the JUMPX
 opcode
Date: Tue, 25 Apr 2017 11:30:38 -0400 (EDT)
Message-ID: <20170425.113038.1100817573569114056.davem@davemloft.net>
References: <1492967848-10165-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, alexei.starovoitov@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948884AbdDYPal (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:30:41 -0400
In-Reply-To: <1492967848-10165-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 23 Apr 2017 13:17:28 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> per discussion at netconf/netdev:
> When we have an action that is capable of branching (example a policer),
> we can achieve a continuation of the action graph by programming a
> "continue" where we find an exact replica of the same filter rule with a lower
> priority and the remainder of the action graph. When you have 100s of thousands
> of filters which require such a feature it gets very inefficient to do two
> lookups.
> 
> This patch completes a leftover feature of action codes. Its time has come.
> 
> Example below where a user labels packets with a different skbmark on ingress
> of a port depending on whether they have/not exceeded the configured rate.
> This mark is then used to make further decisions on some egress port.
> 
>  #rate control, very low so we can easily see the effect
> sudo $TC actions add action police rate 1kbit burst 90k \
> conform-exceed pipe/jump 2 index 10
>  # skbedit index 11 will be used if the user conforms
> sudo $TC actions add action skbedit mark 11 ok index 11
>  # skbedit index 12 will be used if the user does not conform
> sudo $TC actions add action skbedit mark 12 ok index 12
> 
>  #lets bind the user ..
> sudo $TC filter add dev $ETH parent ffff: protocol ip prio 8 u32 \
> match ip dst 127.0.0.8/32 flowid 1:10 \
> action police index 10 \
> action skbedit index 11 \
> action skbedit index 12
> 
>  #run a ping -f and see what happens..
>  #
> jhs@foobar:~$ sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
> filter pref 8 u32
> filter pref 8 u32 fh 800: ht divisor 1
> filter pref 8 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2800 success 1005)
 ...
> Not bad, about 28% non-conforming packets..
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks Jamal.
