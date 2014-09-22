From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] ipv4: do not use this_cpu_ptr() in preemptible
 context
Date: Mon, 22 Sep 2014 13:11:46 -0700
Message-ID: <1411416706.26859.144.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140922090242.5ef15c83@urahara>
	 <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411406513.26859.136.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411407496.26859.141.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx9U1EVmRi4amqVT=MMUvMSqo5907yzM0ytkQNvT74Gu2Q@mail.gmail.com>
	 <20140922190953.GA15929@master> <20140922193451.GA23177@master>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe M <joe9mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:38473 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715AbaIVULr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:11:47 -0400
Received: by mail-pd0-f182.google.com with SMTP id p10so4915671pdj.27
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 13:11:47 -0700 (PDT)
In-Reply-To: <20140922193451.GA23177@master>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-22 at 14:34 -0500, Joe M wrote:
> p --ignore-case --exclude-dir=".git" --recursive this_cpu_ptr *.c
> ip_input.c:             struct ip_rt_acct *st = this_cpu_ptr(ip_rt_acct);
> ip_vti.c:       tstats = this_cpu_ptr(dev->tstats);
> route.c:                p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
> route.c:                        prth = __this_cpu_ptr(nh->nh_pcpu_rth_output);
> tcp.c:          return __this_cpu_ptr(p);
> 
> Is it ok for ip_vti.c and ip_input.c to use this_cpu_ptr?

It is ok.

We run with BH disabled in these contexts.
