From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH 2/3] xfrm: Increase the garbage collector threshold
Date: Fri, 13 Dec 2013 17:13:29 +0100
Message-ID: <1386951209.25449.61.camel@sakura.staff.proxad.net>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
	 <1383294107-7509-3-git-send-email-steffen.klassert@secunet.com>
	 <1386686323.22947.26.camel@sakura.staff.proxad.net>
	 <20131213101203.GO31491@secunet.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:52995 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238Ab3LMQNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 11:13:31 -0500
In-Reply-To: <20131213101203.GO31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2013-12-13 at 11:12 +0100, Steffen Klassert wrote:

> Can you please be a bit more precise with your problem description?

yes sorry I wasn't clear.

I have a problem with an even simpler workload that the one using apache
bench in the original bug report.

I am using ipsec transport mode between two hosts and just run this on
one side:

  while :; do wget -O /dev/null http://remote_host/; done

I was surprised to see it fails after only 1024 requests (ENOBUF on
connect), and how long I had to wait to be able to do new requests.

After debugging I saw that the xfrm gc was called but was not able to
release anything.

after running "ip route flush cache", which forces all ipv4 dst entries
to be released, suddenly the xfrm gc had something to free, and xfrm
entry count went to zero.

So if it is correct that once a ipv4 dst entry exists, the xfrm entry
cannot be gc-ed, then we need to make sure we allow more xfrm entries to
be allocated than ipv4 dst.

> This patch changes only the number of cache entries before
> we start garbage collecting. It does not change anything
> on the garbage collector itself.

Yes my point was that it just hides another underlying problem.

-- 
Maxime
