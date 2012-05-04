From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN
 negociation
Date: Fri, 04 May 2012 23:14:17 +0200
Message-ID: <1336166057.3752.468.camel@edumazet-glaptop>
References: <1336144442.3752.348.camel@edumazet-glaptop>
	 <4FA41B5B.5080103@hp.com> <1336155815.3752.365.camel@edumazet-glaptop>
	 <4FA42491.2020104@hp.com> <1336158359.3752.382.camel@edumazet-glaptop>
	 <4FA43A03.4090707@hp.com>  <4FA43DCE.8040901@hp.com>
	 <1336164546.3752.460.camel@edumazet-glaptop>  <4FA443B6.9010106@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:39902 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760162Ab2EDVOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 17:14:23 -0400
Received: by wibhj6 with SMTP id hj6so1717851wib.1
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 14:14:21 -0700 (PDT)
In-Reply-To: <4FA443B6.9010106@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 14:01 -0700, Rick Jones wrote:
> >
> > Interesting indeed ;)
> >
> > Did you check if it was spoofed ?
> >
> > (did the 3WHS really completed)
> 
> 
> Well, the tcpdump command was still:
> 
> 
> tcpdump -i eth0 -vvv '(tcp[tcpflags]&  tcp-syn != 0)&&  (ip[1] != 0x0)'
> 
> I didn't see any SYN|ACKs go out, but netperf.org would have had to set 
> ECT for me to see a SYN|ACK going out.   FWIW, this is on a 2.6.31-15 
> (Ubuntu) kernel with net.ipv4.tcp_ecn = 2 and I don't think the SYNs 
> themselves were negotiating ECN:
> 
> 13:26:16.866007 IP (tos 0x3,CE, ttl 41, id 28850, offset 0, flags [DF], 
> proto TCP (6), length 64)
>      somesystemin.de.55363 > www.netperf.org.www: Flags [S], cksum 
> 0x4cfc (correct), seq 304457158, win 65535, options [mss 1460,nop,wscale

Probably not, or else you would see :

13:26:16.866007 IP (tos 0x3,CE, ttl 41, id 28850, offset 0, flags
[DF],proto TCP (6), length 64)
    somesystemin.de.55363 > www.netperf.org.www: Flags [SEW], cksum ...
