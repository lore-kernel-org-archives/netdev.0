From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC  2988bis-02.
Date: Thu, 19 May 2011 10:02:07 +0200
Message-ID: <ef84de89c2597793d4cca5eee446ba90@localhost>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net>
 <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net>
 <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
 <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
 <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com>
 <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
 <BANLkTiku9KTHCm59cib5KY8mz0ewSLsHFQ@mail.gmail.com>
 <8C5DF277-320D-4DEB-A133-EEC301DE58DC@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: tsuna <tsunanet@gmail.com>, David Miller <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:46065 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932304Ab1ESICI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 04:02:08 -0400
In-Reply-To: <8C5DF277-320D-4DEB-A133-EEC301DE58DC@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 19 May 2011 08:52:10 +0200, Alexander Zimmermann wrote:



>> #define TCP_RTO_MAX     ((unsigned)(120*HZ))

>> #define TCP_RTO_MIN     ((unsigned)(HZ/5))

>> 

>> So we're talking about a [200ms ; 120s] range no matter what.

> 

> Why is 200ms a valid lower bound for initRTO? I'm aware of

> measurements that 1s is save for Internet, but I don't know of any

> studies that 200ms is save... 



TCP_RTO_MAX and TCP_RTO_MIN is the lower/upper bound for the RTO in

general, not for the initial RTO. RFC 2988 specify a lower bound of 1

second but all operating system choose a lower one because at the time

where RFC 2988 was written the clock granularity was not that accurate. The

minimum RTO for FreeBSD is even 30ms! Furthermore, analysis had

demonstrated that a minimum RTO of 1 second badly breaks throughput in

environments faster then 33kB with minor packet loss rate (e.g. 1%).



So yes, it CAN be wise to choose other lower/upper bounds. But keep in

mind that we should NOT artificial limit ourself. I can image data center

scenarios where a initial RTO of <1 match perfectly.



Hagen
