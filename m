From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 10:09:34 -0800
Message-ID: <5654A7DE.6030005@hpe.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
 <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <1448380194.22599.303.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tom@herbertland.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	kernel-team@fb.com, davewatson@fb.com, alexei.starovoitov@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:41606 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754760AbbKXSJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:09:42 -0500
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com [15.217.128.52])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id A5A016B
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 18:09:39 +0000 (UTC)
In-Reply-To: <1448380194.22599.303.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2015 07:49 AM, Eric Dumazet wrote:
> But in the end, latencies were bigger, because the application had to
> copy from kernel to user (read()) the full message in one go. While if
> you wake up application for every incoming GRO message, we prefill cpu
> caches, and the last read() only has to copy the remaining part and
> benefit from hot caches (RFS up2date state, TCP socket structure, but
> also data in the application)

You can see something similar (at least in terms of latency) when 
messing about with MTU sizes.  For some message sizes - 8KB being a 
popular one - you will see higher latency on the likes of netperf TCP_RR 
with JumboFrames than you would with the standard 1500 byte MTU. 
Something I saw on GbE links years back anyway.  I chalked it up to 
getting better parallelism between the NIC and the host.

Of course the service demands were lower with JumboFrames...

rick jones
