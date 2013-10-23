From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 05:00:01 -0700
Message-ID: <1382529601.7572.2.camel@edumazet-glaptop.roam.corp.google.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
	 <20131022.154638.1989281525248160764.davem@davemloft.net>
	 <20131023081255.GB10148@secunet.com>
	 <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:53736 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab3JWMAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 08:00:06 -0400
Received: by mail-wg0-f54.google.com with SMTP id c11so672617wgh.21
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 05:00:05 -0700 (PDT)
In-Reply-To: <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-23 at 13:33 +0200, Wolfgang Walter wrote:

> I don't know what this value actually means. But on 3.4.x it is much higher. 
> On a machine with 512MB ram it is 32768, on a machine with 1GB ram it is 
> 262144 and with 16GB ram it is 4194304.
> 

Such huge values should not be needed. We should have at most one dst
per packet in flight.

On a loaded router, a NIC not using BQL could queue around 16,000
packets.

Of course, Qdisc layers could also store a lot of packets, but using the
default pfifo_fast is only adding 1000 packets per interface.

I guess using 65536 as the default value should be safe and reasonable

Have you tried using 32768 or 65536 ?
