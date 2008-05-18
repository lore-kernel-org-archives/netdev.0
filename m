From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Sun, 18 May 2008 12:08:42 +0200
Message-ID: <4830002A.4020608@firstfloor.org>
References: <20080515142154.0595e475@core> <482C7DA3.1090809@garzik.org>	 <482C953A.4080205@garzik.org> <87abirytxj.fsf@basil.nowhere.org>	 <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org>	 <20080516121239.GA9627@gondor.apana.org.au>	 <482DB568.1040704@firstfloor.org>	 <20080517010136.GA15102@gondor.apana.org.au>	 <482EBAA8.3040506@firstfloor.org> <a24804730805171254i2a37da61mb47280db7b330ed5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net
To: Chris Peterson <cpeterso@cpeterso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57181 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbYERKIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 06:08:51 -0400
In-Reply-To: <a24804730805171254i2a37da61mb47280db7b330ed5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Peterson wrote:
>> Would people be ok with kernel auto-feeding for /dev/urandom only? I've
>> been pondering that and I think that would work just as well in practice
>>  given the facts above. Then you would still only get blocking
>> /dev/random with the user daemon, but that won't matter because all
>> the usual users don't rely on thatanyways.
> 
> Andi, can you please clarify what you mean by "auto-feeding
> /dev/urandom only" and "only get blocking /dev/random with the user
> daemon"? Are you suggesting that the kernel provides /dev/urandom and
> a userspace daemon (e.g. EGD) provides /dev/random?

What I meant was "only getting working blocking /dev/random
with the user mode daemon". /

The kernel would still provide /dev/random. But on systems
without much entropy (which is pretty common) it will block
often and be unusable unless you run some obscure user space
daemons which regularly refeed /dev/random from hw_random
and stops doing that if the FIPS test fails and makes /dev/random
unusable again.

> Also, if crypto apps like ssh and openssl use on "insecure"
> /dev/urandom, then who actually relies on /dev/random? For comparison,
> FreeBSD does not even (AFAIK) have /dev/urandom. FreeBSD's /dev/random
> is nonblocking (like Linux's /dev/urandom) and includes network
> entropy.

It's sad to say, but their implementation makes more sense than Linux's
(including the feeding in of network data)

I suspect that's the main reason I actually found that many /dev/random
users as I found during my research.

-Andi

