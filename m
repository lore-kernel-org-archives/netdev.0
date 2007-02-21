From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 13:15:51 -0800
Message-ID: <f2b55d220702211315h1266d25el4a0f46c4fb65e12a@mail.gmail.com>
References: <200702191913.08125.dada1@cosmosbay.com>
	 <200702211015.11975.dada1@cosmosbay.com>
	 <20070221092717.GA15669@2ka.mipt.ru>
	 <200702211038.24349.dada1@cosmosbay.com>
	 <20070221095755.GB308@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"David Miller" <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:64651 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423124AbXBUVPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 16:15:53 -0500
Received: by wr-out-0506.google.com with SMTP id i31so2481746wra
        for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 13:15:53 -0800 (PST)
In-Reply-To: <20070221095755.GB308@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Look, Evgeniy.  Eric and I may be morons but davem is not.  He's
telling you, again and again, that DoS attacks do happen, that to
survive them you need for the distribution of tuples within hash
buckets to vary unpredictably from system to system and boot to boot,
and that XOR hash does not accomplish this.  He has told you that the
Jenkins hash works, for reasons discussed exhaustively in the link I
gave you, which you can follow to statistical analysis that is beyond
your expertise or mine.  He has told you that your performance
analysis is fundamentally flawed.  Do you think you might need to drop
back five and punt?

As for the distribution issues:  who cares?  You fundamentally can't
do any better, for random input drawn from a tuple space much larger
than the number of hash buckets, than a Poisson distribution.  And
that's enough to kill a naive hash table design, because chaining is
going to cost you another cache miss for every link, and you couldn't
afford the first cache miss in the first place.  If you absolutely
insist on a hash table (on the theory that you can't keep the hot
connections warm in cache anyway, which isn't necessarily true if you
use a splay tree), it had better be a 2-left hash with a compact
overflow pool for the rare case of second collision.

I recommend Michael Mitzenmacher's paper to you, or rather to
whoever's reading along with the intention of improving the kernel
without reinventing the square wheel.

Cheers,
- Michael
