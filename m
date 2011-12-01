From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] netem: fix build error on 32bit arches
Date: Thu, 1 Dec 2011 11:04:35 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEF7@saturn3.aculab.com>
References: <1322731934.2335.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Hagen Paul Pfeifer" <hagen@jauu.net>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35379 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752781Ab1LALGh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 06:06:37 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22993-10 for <netdev@vger.kernel.org>;
 Thu,  1 Dec 2011 11:06:34 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1322731934.2335.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> +	u64 ticks = (u64)len * NSEC_PER_SEC;
Writing:
	u64 ticks = len * (u64)NSEC_PER_SEC;
probably generates better code since the compiler
is much more likely to spot that a single 32x32 -> 64
multiply is adequate.

	David
