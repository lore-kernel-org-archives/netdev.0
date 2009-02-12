From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Thu, 12 Feb 2009 08:46:49 -0500
Message-ID: <f73f7ab80902120546w2ac30501v10fc55b9c8270be9@mail.gmail.com>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>
	 <20090212001223.GA5757@movementarian.org>
	 <alpine.DEB.2.00.0902121006440.18739@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: wli@movementarian.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0902121006440.18739@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 12, 2009 at 4:11 AM, Jozsef Kadlecsik
<kadlec@blackhole.kfki.hu> wrote:
> The current jhash.h implements the lookup2() hash function by Bob Jenkins.
> However, lookup2() is outdated as Bob wrote a new hash function called
> lookup3(). The new hash function
>
> - mixes better than lookup2(): it passes the check that every input bit
>  changes every output bit 50% of the time, while lookup2() failed it.
> - performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% faster
>  than lookup2() depending on the key length.

Well, there's another question which is not addressed by Bob Jenkins'
design docs:

Kernel code usually runs cache-cold, whereas Bob Jenkins did most of
his testing cache-hot in tight loops.  If you compile both lookup2 and
lookup3 with -Os and run them in a loop with a cache flush, how well
do they compare then?

Cheers,
Kyle Moffett
