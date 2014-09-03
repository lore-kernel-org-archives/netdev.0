From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: High perf top ip_idents_reserve doing netperf UDP_STREAM
Date: Wed, 03 Sep 2014 08:17:06 -0700
Message-ID: <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36658 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbaICPRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 11:17:12 -0400
Received: by mail-pd0-f179.google.com with SMTP id z10so11282958pdj.24
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 08:17:09 -0700 (PDT)
In-Reply-To: <20140903165943.372b897b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 16:59 +0200, Jesper Dangaard Brouer wrote:
> Hi Eric,
> 
> When doing:
>  super_netperf 120 -H 192.168.8.2 -t UDP_STREAM -l 100 -- -m 256
> 
> I'm seeing function ip_idents_reserve() consuming most CPU.  Could you
> help, explain what is going on, and how I can avoid this?
> 
> Perf top:
>   11.67%  [kernel]   [k] ip_idents_reserve
>    8.37%  [kernel]   [k] fib_table_lookup
>    4.46%  [kernel]   [k] _raw_spin_lock
>    3.21%  [kernel]   [k] copy_user_enhanced_fast_string
>    2.92%  [kernel]   [k] sock_alloc_send_pskb
>    2.88%  [kernel]   [k] udp_sendmsg
> 

Because you use a single destination, all flows compete on a single
atomic to get their next IP identifier.

You can try to use netperf options  (-- -N -n) so that netperf uses
connected UDP sockets.

In this case, the IP identifier generator is held in each socket.
