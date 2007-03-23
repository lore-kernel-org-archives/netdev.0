From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: XOR hash beauty solved [Was: RFC: Established connections hash function]
Date: Fri, 23 Mar 2007 14:58:05 +0300
Message-ID: <20070323115805.GA23480@2ka.mipt.ru>
References: <391F64D0A7C5463CA2D70362E4B3E7EC@XEON> <20070322182156.GB17793@2ka.mipt.ru> <1199CE22A40740D28833A585014BE559@XEON> <20070322.135834.74723088.davem@davemloft.net> <20070323080715.GB29991@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: nikb@webmaster.com, netdev@vger.kernel.org,
	Eric Dumazet <dada1@cosmosbay.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48031 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422791AbXCWL7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 07:59:12 -0400
Content-Disposition: inline
In-Reply-To: <20070323080715.GB29991@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Please, do not apply patch as is, I will devote this day to find where
> jenkins has problems and try to fix distribution. If I will fail, then
> it is up to you to decide that above results are bad or good.

I need to admit that I was partially wrong in my analysis of the Jenkins
hash distribution - it does _not_ have problems and any kind of artifacts. 
Waves found in tests are results of folding into hash_size boundary,
distribution inside F(32) field is unifirm.
XOR hash does not have such problem, because it uses (u32 ^ u16) as one
round, which results in the uniform (it is not correct to call that
distribution uniform as is, but only getting into account that u16 values 
used in tests were uniformly distributed) distribution inside F(16), which 
does not suffer from hash_size boundary folding. Since XOR hash has 3 rounds, 
only one of them (xor of the final u32 values) will suffer from folding, but 
tests where is it can be determined for sure use constant addresses, so 
problem hides again.

So, briefly saying, jhash_2/3words have safe distribution, but have
higher-number of elements waves as a result of folding which is
unavoidable for general-purpose hash.

Now my conscience is calm :)

-- 
	Evgeniy Polyakov
