From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tc filters: add support to get individual
 filters by handle
Date: Wed, 12 Oct 2016 15:26:55 -0700
Message-ID: <20161012152655.536a6749@xeon-e3>
References: <1476117914-32207-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35204 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752672AbcJLWer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 18:34:47 -0400
Received: by mail-pa0-f42.google.com with SMTP id qn10so32101795pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 15:34:46 -0700 (PDT)
In-Reply-To: <1476117914-32207-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Oct 2016 12:45:14 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> sudo $TC filter add dev $ETH parent ffff: prio 2 protocol ip \
> u32 match u32 0 0 flowid 1:1 \
> action ok
> sudo $TC filter add dev $ETH parent ffff: prio 1 protocol ip \
> u32 match ip protocol 1 0xff flowid 1:10 \
> action ok
> 
> now dump to see all rules..
> $TC -s filter ls dev $ETH parent ffff: protocol ip
>  ....
> filter pref 1 u32
> filter pref 1 u32 fh 801: ht divisor 1
> filter pref 1 u32 fh 801::800 order 2048 key ht 801 bkt 0 flowid 1:10  (rule hit 0 success 0)
>   match 00010000/00ff0000 at 8 (success 0 )
>         action order 1: gact action drop
>          random type none pass val 0
>          index 6 ref 1 bind 1 installed 4 sec used 4 sec
>         Action statistics:
>         Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>         backlog 0b 0p requeues 0
> 
> filter pref 2 u32
> filter pref 2 u32 fh 800: ht divisor 1
> filter pref 2 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1  (rule hit 336 success 336)
>   match 00000000/00000000 at 0 (success 336 )
>         action order 1: gact action pass
>          random type none pass val 0
>          index 5 ref 1 bind 1 installed 38 sec used 4 sec
>         Action statistics:
>         Sent 24864 bytes 336 pkt (dropped 0, overlimits 0 requeues 0)
>         backlog 0b 0p requeues 0
>  ....
> 
> ..get filter 801::800
> $TC -s filter get dev $ETH parent ffff: protocol ip \
> handle 801:0:800 prio 2  u32
> 
>  ....
> filter parent ffff: protocol ip pref 1 u32 fh 801::800 order 2048 key ht 801 bkt 0 flowid 1:10  (rule hit 260 success 130)
>   match 00010000/00ff0000 at 8 (success 130 )
>         action order 1: gact action drop
>          random type none pass val 0
>          index 6 ref 1 bind 1 installed 348 sec used 0 sec
>         Action statistics:
>         Sent 11440 bytes 130 pkt (dropped 130, overlimits 0 requeues 0)
>         backlog 0b 0p requeues 0
>  ....
> 
> ..get other one
> $TC -s filter get dev $ETH parent ffff: protocol ip \
> handle 800:0:800 prio 2  u32
> 
> ....
> filter parent ffff: protocol ip pref 2 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1  (rule hit 514 success 514)
>   match 00000000/00000000 at 0 (success 514 )
>         action order 1: gact action pass
>          random type none pass val 0
>          index 5 ref 1 bind 1 installed 506 sec used 4 sec
>         Action statistics:
>         Sent 35544 bytes 514 pkt (dropped 0, overlimits 0 requeues 0)
>         backlog 0b 0p requeues 0
> ....
> 
> ..try something that doesnt exist
> $TC -s filter get dev $ETH parent ffff: protocol ip  handle 800:0:803 prio 2  u32
> 
> .....
> RTNETLINK answers: No such file or directory
> We have an error talking to the kernel
> .....
> 
> Note, added NLM_F_ECHO is for backward compatibility. old kernels never
> before Eric's patch will not respond without it and newer kernels (after Erics patch)
> will ignore it.
> In old kernels there is a side effect:
> In addition to a response to the GET you will receive an event (if you do tc mon).
> But this is still better than what it was before (not working at all).
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied
