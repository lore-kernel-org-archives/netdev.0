From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Netperf UDP issue with connected sockets
Date: Fri, 18 Nov 2016 02:37:09 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1611180145580.2135@ja.home.ssi.bg>
References: <20140903165943.372b897b@redhat.com> <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com> <20161116131609.4e5726b4@redhat.com> <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com> <20161116234022.2bad179b@redhat.com>
 <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com> <20161117091638.5fab8494@redhat.com> <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com> <20161117144248.23500001@redhat.com> <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117155753.17b76f5a@redhat.com> <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com> <20161117193021.580589ae@redhat.com> <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com> <20161117221941.3b525181@redhat.com>
 <1479419042.8455.280.camel@edumazet-glaptop3.roam.corp.google.com> <d7d209a8-6142-2599-3303-19640d340b97@hpe.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:32933 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752149AbcKRAhh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 19:37:37 -0500
In-Reply-To: <d7d209a8-6142-2599-3303-19640d340b97@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 17 Nov 2016, Rick Jones wrote:

> raj@tardy:~/netperf2_trunk$ strace -v -o /tmp/netperf.strace src/netperf -F
> src/nettest_omni.c -t UDP_STREAM -l 1 -- -m 1472
> 
> ...
> 
> socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 4
> getsockopt(4, SOL_SOCKET, SO_SNDBUF, [212992], [4]) = 0
> getsockopt(4, SOL_SOCKET, SO_RCVBUF, [212992], [4]) = 0
> setsockopt(4, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> bind(4, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.0.0")},
> 16) = 0
> setsockopt(4, SOL_SOCKET, SO_DONTROUTE, [1], 4) = 0

	connected socket can benefit from dst cached in socket
but not if SO_DONTROUTE is set. If we do not want to send packets
via gateway this -l 1 should help but I don't see IP_TTL setsockopt
in your first example with connect() to 127.0.0.1.

	Also, may be there can be another default, if -l is used to
specify TTL then SO_DONTROUTE should not be set. I.e. we should
avoid SO_DONTROUTE, if possible.

Regards
