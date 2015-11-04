From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Wed, 04 Nov 2015 04:40:51 -0800
Message-ID: <1446640851.4184.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
	 <19837690.PaPkekjCr9@stwm.de>
	 <1446556053.23275.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3363088.63t9TqhiQf@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34670 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965135AbbKDMky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 07:40:54 -0500
Received: by padhx2 with SMTP id hx2so44546907pad.1
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 04:40:53 -0800 (PST)
In-Reply-To: <3363088.63t9TqhiQf@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-04 at 13:19 +0100, Wolfgang Walter wrote:

> Today I found a problem: on a router forwarding GRE-packets (ipv4) (it is not 
> the endpount) the interface (intel igb) stops sending packets after some time. 
> I think this happens when an ISATAP packet is inside the GRE-packet.
> 
> 	gre packets arrives on eth0
> 	eth1 stops sending (receiving still works)
> 	ethtool -r eth1
> 	eth1 works again for some time
> 
> Switching GRO off on eth0 "fixes" the problem.
> 
> I didn't test vanilla 4.1.12 yet, though. Until today 4.1.11 has been running 
> on the router. What I tested was your patch
> 	"gre_gso_segment() chokes if SIT frames were aggregated by GRO engine."
> but did not solve the problem.
> 
> So I would not recommend to backport it to longterm 4.1.
> 
> My plans are:
> 
> * test vanilla 4.1.12
> * test 4.3
> 
> I want to test 4.3 on another router first, though.

If the NIC stops sending packets after some time, it might be an igb
issue.
