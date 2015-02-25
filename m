From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 19:56:08 +0100
Message-ID: <54EE1AC8.6060206@iogearbox.net>
References: <cover.1424877322.git.daniel@iogearbox.net>	 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>	 <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>	 <54EDEE55.8050605@iogearbox.net>	 <063D6719AE5E284EB5DD2968C1650D6D1CAED3A1@AcuExch.aculab.com>	 <54EDF4DD.1060709@iogearbox.net> <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41882 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbbBYS4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 13:56:24 -0500
In-Reply-To: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 06:41 PM, Eric Dumazet wrote:
...
> There is no need to track number of elements, using either an atomic_t
> or percpu_counter. This adds unnecessary burden.
>
> 1) Automatic shrinking is a non issue. This will free very little
> memory, compared to previous peak usage (including objects put in
> rhashtable). If hash grown to a certain point, it's likely it will grow
> again later.

So you are saying that shrinking is most likely a rather undesirable
use-case in rhashtable?

> 2) Growing can be triggered when any bucket has more than X elems, and
> that is given for free at insert time.
> X could be log2(buckets)/2 I guess. (aka shift/2)

Yes, I think such a facility can be added easily.

> A global limit on number of elements should be controlled by rhashtable
> users - if needed -, not in the rhashtable itself.

Makes sense, thanks for the suggestion! I'll experiment with the above
per bucket tracking a bit if you're okay with that, and also unfiddle
the rht counter internals from netlink.

Thanks,
Daniel
