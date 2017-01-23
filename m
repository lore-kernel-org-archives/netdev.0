From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 1/1] net sched actions: Add support for user
 cookies
Date: Mon, 23 Jan 2017 08:48:05 +0100
Message-ID: <20170123074805.GA1831@nanopsycho.orion>
References: <1485116750-31198-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36751 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAWHsI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 02:48:08 -0500
Received: by mail-wm0-f68.google.com with SMTP id r126so24317038wmr.3
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 23:48:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485116750-31198-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jan 22, 2017 at 09:25:50PM CET, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>Introduce optional 128-bit action cookie.
>Like all other cookie schemes in the networking world (eg in protocols
>like http or existing kernel fib protocol field, etc) the idea is to save
>user state that when retrieved serves as a correlator. The kernel
>_should not_ intepret it.  The user can store whatever they wish in the
>128 bits.
>
>Sample exercise(showing variable length use of cookie)
>
>.. create an accept action with cookie a1b2c3d4
>sudo $TC actions add action ok index 1 cookie a1b2c3d4
>
>.. dump all gact actions..
>sudo $TC -s actions ls action gact
>
>    action order 0: gact action pass
>     random type none pass val 0
>     index 1 ref 1 bind 0 installed 5 sec used 5 sec
>    Action statistics:
>    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>    cookie a1b2c3d4
>
>.. bind the accept action to a filter..
>sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
>u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 1
>
>... send some traffic..
>$ ping 127.0.0.1 -c 3
>PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
>64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.020 ms
>64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.027 ms
>64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.038 ms
>
>--- 127.0.0.1 ping statistics ---
>3 packets transmitted, 3 received, 0% packet loss, time 2109ms
>rtt min/avg/max/mdev = 0.020/0.028/0.038/0.008 ms 1
>
>... show some stats
>$ sudo $TC -s actions get action gact index 1
>
>    action order 1: gact action pass
>     random type none pass val 0
>     index 1 ref 2 bind 1 installed 204 sec used 5 sec
>    Action statistics:
>        Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>    cookie a1b2c3d4
>
>.. try longer cookie...
>$ sudo $TC actions replace action ok index 1 cookie 1234567890abcdef
>.. dump..
>$ sudo $TC -s actions ls action gact
>
>    action order 1: gact action pass
>     random type none pass val 0
>     index 1 ref 2 bind 1 installed 204 sec used 5 sec
>    Action statistics:
>        Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>    cookie 1234567890abcdef
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
