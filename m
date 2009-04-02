From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor	implementation
 & Netlink protocol
Date: Thu, 02 Apr 2009 17:06:40 +0200
Message-ID: <49D4D480.9030306@trash.net>
References: <20090304.030044.163418715.davem@davemloft.net> <20090402093952.GA30553@gondor.apana.org.au> <20090402.025223.242893473.davem@davemloft.net> <20090402095957.GA30799@gondor.apana.org.au> <49D4CECA.3010703@trash.net> <20090402144549.GA764@gondor.apana.org.au> <49D4D260.6020809@trash.net> <20090402145952.GA1276@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47591 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763315AbZDBPGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 11:06:46 -0400
In-Reply-To: <20090402145952.GA1276@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 04:57:36PM +0200, Patrick McHardy wrote:
>> I didn't spot the problem, it seems it alreay copies all (sub)structures
>> that have larger alignment requirements.
> 
> Oh no I didn't mean that xfrm_userpolicy_info has a problem, for
> all I know it might not even have a u64 inside :)

:)

> If we can ensure that all netlink backends use the helpers that
> copy, even for structures then it should definitely work.

Yes, that should always work. For new stuff I think we should try
to avoid encapsulating larger structures in single attributes though
since it forces us to do copy everything, instead of just the types
that really require it (and the padding issues in case of at least
non-priviledged interfaces).

