From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 13:42:59 -0700
Message-ID: <1432586579.4060.184.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432579766.32671.66.camel@jasiiieee.pacifera.com>
	 <1432580733.4060.178.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432581685.32671.80.camel@jasiiieee.pacifera.com>
	 <1432586494.4060.183.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34651 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbEYUnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 16:43:00 -0400
Received: by ieczm2 with SMTP id zm2so78734584iec.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 13:43:00 -0700 (PDT)
In-Reply-To: <1432586494.4060.183.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 13:41 -0700, Eric Dumazet wrote:

> lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 10.7.8.152 -Cc -t OMNI -l 20
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.7.8.152 () port 0 AF_INET
> tcpi_rto 281000 tcpi_ato 0 tcpi_pmtu 1476 tcpi_rcv_ssthresh 28720
> tcpi_rtt 80431 tcpi_rttvar 304 tcpi_snd_ssthresh 2147483647 tpci_snd_cwnd 2215
> tcpi_reordering 3 tcpi_total_retrans 0
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
> Final       Final                                             %     Method %      Method                          
> 4194304     6291456     16384  20.17   149.54     10^6bits/s  0.40  S      0.78   S      10.467  20.554  usec/KB  
> 
> 
> Now with 16MB I got :
> 

Sorry message was sent too soon :

lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 10.7.8.152 -Cc -t OMNI -l 20
OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.7.8.152 () port 0 AF_INET
tcpi_rto 281000 tcpi_ato 0 tcpi_pmtu 1476 tcpi_rcv_ssthresh 28720
tcpi_rtt 80438 tcpi_rttvar 25 tcpi_snd_ssthresh 2147483647 tpci_snd_cwnd 5895
tcpi_reordering 3 tcpi_total_retrans 0
Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
Final       Final                                             %     Method %      Method                          
16777216    16777216    16384  20.31   399.75     10^6bits/s  0.55  S      0.65   S      5.375   6.416   usec/KB  
