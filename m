From: Mark Huth <mhuth@mvista.com>
Subject: Re: [PATCH][af_key]pfkey_add: Optimize SA adds and algorithm probes
Date: Thu, 24 May 2007 17:15:30 -0700
Message-ID: <46562AA2.8030102@mvista.com>
References: <4643CD64.4090000@mvista.com> <E1HouAO-0003i5-00@gondolin.me.apana.org.au> <20070518212148.GA25363@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:20537 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbXEYAPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 20:15:33 -0400
In-Reply-To: <20070518212148.GA25363@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




Herbert Xu wrote:
> On Fri, May 18, 2007 at 02:34:12PM +1000, Herbert Xu wrote:
>> Actually, I think we should just probe for the specific algorithm
>> requested rather than everything.  See patch below.
> 
> Doh, forgot to actually remove the probe call :)
> 
> [IPSEC] pfkey: Load specific algorithm in pfkey_add rather than all
> 
> This is a natural extension of the changeset
> 
>     [XFRM]: Probe selected algorithm only.
> 
> which only removed the probe call for xfrm_user.  This patch does exactly
> the same thing for af_key.  In other words, we load the algorithm requested
> by the user rather than everything when adding xfrm states in af_key.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,

[... snip]

Herbert,

I can verify that this works.  The test adds 2000 instances of SAs using
hmac-md5 for authentication and rijndael-cbc for encryption.
Test output is:

root@192.168.150.94:~# lsmod
Module                  Size  Used by
root@192.168.150.94:~#time setkey -f SA_test.txt

real    0m1.072s
user    0m0.048s
sys     0m0.632s
root@192.168.150.94:~#lsmod
Module                  Size  Used by
twofish                10112  0
twofish_common         40192  1 twofish
camellia               32768  0
serpent                25216  0
blowfish                9984  0
ecb                     3712  0
aes                    28864  2000
xcbc                    5768  0
sha256                 12416  0
crypto_null             3456  0

root@192.168.150.94:~#

Prior to the patch time was over 42 seconds (possibly longer on 2.6.21).

I'm a bit curious why all of the crypto modules got loaded, but it 
doesn't matter.

Thanks for the patch.

Mark Huth
