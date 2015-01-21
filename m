From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 11:37:51 +0000
Message-ID: <20150121113751.GT20315@casper.infradead.org>
References: <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
 <20150121093722.GM20315@casper.infradead.org>
 <20150121093836.GA25489@gondor.apana.org.au>
 <20150121094928.GN20315@casper.infradead.org>
 <20150121095837.GA25750@gondor.apana.org.au>
 <20150121103421.GR20315@casper.infradead.org>
 <20150121103959.GR3012@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36203 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbbAULhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:37:54 -0500
Content-Disposition: inline
In-Reply-To: <20150121103959.GR3012@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/15 at 10:40am, Patrick McHardy wrote:
> On the danger of repeating myself, every (converted) user requires
> that we at least keep the existing semantics since it is exposed to
> userspace. My opinion is that NLM_F_DUMP_INTR is fine if userspace
> indicates support, but without that, we have to take care of that
> in the kernel.

Absolutely agreed. I think this is an excellent low cost path for
future users where dumps are rare.

> An automatic restart handles this well. Userspace always had to
> expect duplicates.

Maybe I don't understand the restart yet. How do you restart if the
dump was already started and the user has read part of the dump?
