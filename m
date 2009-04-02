From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor	implementation
 & Netlink protocol
Date: Thu, 02 Apr 2009 16:57:36 +0200
Message-ID: <49D4D260.6020809@trash.net>
References: <20090304.030044.163418715.davem@davemloft.net> <20090402093952.GA30553@gondor.apana.org.au> <20090402.025223.242893473.davem@davemloft.net> <20090402095957.GA30799@gondor.apana.org.au> <49D4CECA.3010703@trash.net> <20090402144549.GA764@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47325 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761551AbZDBO5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 10:57:42 -0400
In-Reply-To: <20090402144549.GA764@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 04:42:18PM +0200, Patrick McHardy wrote:
>> Actually we should be fine since the current netlink helpers only do
>> bytewise copying anyways. And I think we've pretty much gotten rid of
>> all the raw attribute accesses.
> 
> What about stuff like xfrm_userpolicy_info? I suppose if *everything*
> is copied then it wouldn't matter.

I didn't spot the problem, it seems it alreay copies all (sub)structures
that have larger alignment requirements.

Presuming I simply missed it, I think it would be best to gradually
move to a set of nested attributes since some of the structures also
have holes that are currently not cleared during dumping (I guess not
a big deal since its root-only) and IIRC there are some 32/64 bit
compatibility issues.

