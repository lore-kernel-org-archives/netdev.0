From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Thu, 21 Jul 2011 22:18:09 -0300
Message-ID: <4E28CFD1.2030504@gont.com.ar>
References: <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<4E2781A2.8020905@gont.com.ar>	<20110721.151750.995903739612693126.davem@davemloft.net> <4E28B84C.2090305@gont.com.ar> <4E28C58E.1080501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	security@kernel.org, eugeneteo@kernel.sg, netdev@vger.kernel.org,
	mpm@selenic.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:46543 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab1GVBST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 21:18:19 -0400
Received: by yia27 with SMTP id 27so951086yia.19
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 18:18:18 -0700 (PDT)
In-Reply-To: <4E28C58E.1080501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2011 09:34 PM, Rick Jones wrote:
>> That scenario assumes packet reordering and/or packet loss.
> 
> Isn't that a given?  

I mean that if these "collisions" of Identification numbers are of
concern, then, then, at such bandwidth rates, fragmentation itself would
be a concern.

Chances of collisions are proportional to reordering and losses. That
means that at such bandwidths, you'd need to be able to queue a huge
number of packets (which you might not be able to queue, becacuse of
lack of resources), etc.



> And indeed, fragmentation is considered bad, and was considered bad
> enough that the "revenge of the router guys" that is IPv6 punted it to
> the end systems, and yes, one should use PMTUD. Which is all well and
> good when 999 times out of 1 traffic is flowing over a transport that
> does its own segmentation and reassembly.  

And provided that there's no ICMPv6 filtering out there (which there is)
-- at which point you need to implement some for of blackhole detection
a la PLMPTUD.


> And when IPv6 got spec'ed it
> looked to all the world that UDP was on the way out - NFS was migrating
> over to TCP, and DNS was "never" more than 512 byte messages. No problem
> right?  But since then we've gotten things like EDNS which will be
> sending DNS messages in UDP datagrams that will have to be fragmented,
> PMTUD notwithstanding.

Hopefully you won't have the aforementioned 40GB traffic rate between
two DNS servers ;-)

Thanks,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1



