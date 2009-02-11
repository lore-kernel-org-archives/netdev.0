From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Tue, 10 Feb 2009 17:17:38 -0800 (PST)
Message-ID: <20090210.171738.65421666.davem@davemloft.net>
References: <alpine.DEB.2.00.0902102026060.10299@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55115
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755516AbZBKBRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 20:17:44 -0500
In-Reply-To: <alpine.DEB.2.00.0902102026060.10299@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Tue, 10 Feb 2009 20:40:47 +0100 (CET)

> Please consider applying the following patch:
> 
> The current jhash.h implements the lookup2() hash function by Bob Jenkins. 
> However, lookup2() is outdated as Bob wrote a new hash function called 
> lookup3(). The new hash function
> 
> - mixes better than lookup2(): it passes the check that every input bit 
>   changes every output bit 50% of the time, while lookup2() failed it.
> - performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% faster
>   than lookup2() depending on the key length.
> 
> The patch replaces the lookup2() implementation of the 'jhash*' 
> functions with that of lookup3().
> 
> You can read a longer comparison of the two and other hash functions at 
> http://burtleburtle.net/bob/hash/doobs.html.
> 
> Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

I support this change and I also don't think it makes sense
to have a jhash3.h new header file, that's just a waste of
time.  Either the new stuff is better or it isn't, and that
whole "matching hashes" argument is pure garbage.

But this kind of change isn't for me to decide, changing jhash
impacts the entire tree not just networking, and also I know
that Rusty Russell was investigating making this change and
he even did his own timings on various platforms.

Therefore this needs to be proposed on linux-kernel with appropriate
parties CC:'d.

Thanks.
