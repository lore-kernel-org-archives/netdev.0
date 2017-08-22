From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Tue, 22 Aug 2017 06:02:06 -0700
Message-ID: <1503406926.2499.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
         <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
         <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
         <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
         <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
         <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
         <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
         <1503337498.2499.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34930 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932638AbdHVNCJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 09:02:09 -0400
Received: by mail-pf0-f179.google.com with SMTP id w127so15537710pfd.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 06:02:08 -0700 (PDT)
In-Reply-To: <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-22 at 11:12 +0530, Akshat Kakkar wrote:
> There are multiple hosts/clients. All are mainly windows based.
> 
> Timestamp is not used as my clients mainly are windows based and in
> that it tcp timestamp is by defauly disabled.
> 
> sysctl is as follows:
> 
> kernel.shmmax = 68719476736
> kernel.shmall = 4294967296
> kernel.pid_max=4194303
> vm.max_map_count=131072
> kernel.sem=250 32000 32 250
> 
> net.netfilter.nf_conntrack_generic_timeout = 300
> net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 60
> net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 30
> net.netfilter.nf_conntrack_tcp_timeout_established = 7200
> net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 60
> net.netfilter.nf_conntrack_tcp_timeout_close_wait = 30
> net.netfilter.nf_conntrack_tcp_timeout_last_ack = 30
> net.netfilter.nf_conntrack_tcp_timeout_time_wait = 60
> net.netfilter.nf_conntrack_tcp_timeout_close = 10
> net.netfilter.nf_conntrack_tcp_timeout_max_retrans = 300
> net.netfilter.nf_conntrack_tcp_timeout_unacknowledged = 300
> net.netfilter.nf_conntrack_udp_timeout = 30
> net.netfilter.nf_conntrack_udp_timeout_stream = 180
> net.netfilter.nf_conntrack_icmp_timeout = 30
> net.netfilter.nf_conntrack_events_retry_timeout = 15
> net.core.rmem_max = 8388608
> net.core.wmem_max = 8388608
> 
> net.ipv4.tcp_tw_reuse=1
> net.ipv4.tcp_tw_recycle=1

This is exactly what I feared.

We do not support tcp_tw_reuse = 1 AND tcp_tw_recycle = 1

This is a very well known bad combination.



> net.ipv4.tcp_fin_timeout=30
> net.ipv4.tcp_keepalive_time=1800
> net.ipv4.tcp_keepalive_intvl=60
> net.ipv4.tcp_keepalive_probes=20
> net.ipv4.tcp_max_syn_backlog=4096
> net.ipv4.tcp_syncookies=1
> net.ipv4.tcp_sack=1
> net.ipv4.tcp_dsack=1
> net.ipv4.tcp_window_scaling=1
> net.ipv4.tcp_syn_retries=3
> net.ipv4.tcp_synack_retries=3
> net.ipv4.tcp_retries1=3
> net.ipv4.tcp_retries2=15
> net.ipv4.ip_local_port_range=1024    65535
> 
> net.ipv4.tcp_timestamps=0
> 
> net.core.netdev_max_backlog=10000

This is an insane backlog.

> net.core.somaxconn=100000
> net.core.optmem_max=81920
> 
> net.netfilter.nf_conntrack_max=524288
> net.nf_conntrack_max=524288
> net.ipv6.conf.all.disable_ipv6 = 1
> fs.file-max=1000000
> 
> net.ipv4.tcp_no_metrics_save = 1
> net.ipv4.tcp_max_syn_backlog = 10240
> net.ipv4.tcp_congestion_control=htcp
> 
> net.ipv4.tcp_rfc1337 = 1
> net.core.netdev_max_backlog = 65536

This is a crazy backlog. Do not do that.


> net.ipv4.tcp_max_tw_buckets = 1440000
> 
> net.core.rmem_max = 134217728
> net.core.wmem_max = 134217728
> 
> 
> 


It looks like your sysctls have been set to unreasonable values.
