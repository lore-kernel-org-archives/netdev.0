From: Patrick McHardy <kaber@trash.net>
Subject: Re: call panic if nl_table allocation fails
Date: Wed, 23 Aug 2006 16:17:04 +0200
Message-ID: <44EC6360.9070109@trash.net>
References: <20060823113740.GA7834@miraclelinux.com> <Pine.LNX.4.64.0608231003340.3198@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Akinobu Mita <mita@miraclelinux.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63990 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964894AbWHWORK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 10:17:10 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0608231003340.3198@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Wed, 23 Aug 2006, Akinobu Mita wrote:
> 
> 
>>This patch makes crash happen if initialization of nl_table fails
>>in initcalls. It is better than getting use after free crash later.
> 
> 
>> 	nl_table = kcalloc(MAX_LINKS, sizeof(*nl_table), GFP_KERNEL);
> 
> 
> Perhaps it'd be better to declare this as an array rather than allocating 
> it at runtime.

That would still leave the MAX_LINKS allocations for the pid hashes
which need to be allocated because they are dynamically sized. We
could delay the pid hash allocations until the first bind happens
of course, but I doubt it would be worth it since they start with
just a single bucket.

