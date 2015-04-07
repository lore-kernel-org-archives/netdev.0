From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Tue, 07 Apr 2015 12:49:49 -0700
Message-ID: <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>
	 <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:32994 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbbDGTtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:49:51 -0400
Received: by ignm3 with SMTP id m3so16063493ign.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 12:49:51 -0700 (PDT)
In-Reply-To: <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-07 at 11:54 +0200, Jan Engelhardt wrote:
> On Tuesday 2015-04-07 04:48, Eric Dumazet wrote:
> >On Tue, 2015-04-07 at 00:45 +0200, Jan Engelhardt wrote:
> >> I have here a Linux 3.19(.0) system where activated TSO on a veth slave 
> >> device makes IPv4-TCP transfers going into that veth-connected container 
> >> progress slowly.
> >
> >Nothing comes to mind. It would help if you could provide a script to
> >reproduce the issue.
> 
> It seems IPsec is *also* a requirement in the mix.
> Anyhow, script time!

I tried your scripts, but the sender does not use veth ?

Where is the part you disable TSO ?
If its on the receiver, I fail to understand how it matters.

+ DUMP_TCP_INFO=1 ./netperf -H 10.10.23.23 -l 10
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
10.10.23.23 () port 0 AF_INET
tcpi_rto 217000 tcpi_ato 0 tcpi_pmtu 1438 tcpi_rcv_ssthresh 29200
tcpi_rtt 16715 tcpi_rttvar 7 tcpi_snd_ssthresh 702 tpci_snd_cwnd 831
tcpi_reordering 3 tcpi_total_retrans 24
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.03     577.53   

Seems OK to me ?
