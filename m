From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] actions: Add support for user cookies
Date: Sun, 23 Apr 2017 09:11:09 -0700
Message-ID: <20170423091109.79d47f6b@xeon-e3>
References: <1492864583-20892-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35392 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045873AbdDWQLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 12:11:12 -0400
Received: by mail-io0-f172.google.com with SMTP id r16so153952603ioi.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 09:11:12 -0700 (PDT)
In-Reply-To: <1492864583-20892-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Apr 2017 08:36:23 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Make use of 128b user cookies
> 
> Introduce optional 128-bit action cookie.
> Like all other cookie schemes in the networking world (eg in protocols
> like http or existing kernel fib protocol field, etc) the idea is to
> save user state that when retrieved serves as a correlator. The kernel
> _should not_ intepret it. The user can store whatever they wish in the
> 128 bits.
> 
> Sample exercise(showing variable length use of cookie)
> 
> .. create an accept action with cookie a1b2c3d4
> sudo $TC actions add action ok index 1 cookie a1b2c3d4
> 
> .. dump all gact actions..
> sudo $TC -s actions ls action gact
> 
>     action order 0: gact action pass
>      random type none pass val 0
>      index 1 ref 1 bind 0 installed 5 sec used 5 sec
>     Action statistics:
>     Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
>     cookie a1b2c3d4
> 
> .. bind the accept action to a filter..
> sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
> u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 1
> 
> ... send some traffic..
> $ ping 127.0.0.1 -c 3
> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.020 ms
> 64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.027 ms
> 64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.038 ms
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied. Please update man page as well.
