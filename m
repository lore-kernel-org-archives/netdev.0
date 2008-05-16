From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
 few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 18:20:13 +0200
Message-ID: <482DB43D.2090504@firstfloor.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515173939.1ec968be@core> <482C7DA3.1090809@garzik.org> <482C953A.4080205@garzik.org> <87abirytxj.fsf@basil.nowhere.org> <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org> <20080516132049.GC8029@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49355 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbYEPQUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 12:20:21 -0400
In-Reply-To: <20080516132049.GC8029@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> On Fri, May 16, 2008 at 12:19:49PM +0200, Andi Kleen wrote:
>> ...
>> The only problem you got from possible bogus input is that the entropy
>> counts will be wrong, but in my experience nearly all programs
>> use /dev/urandom anyways because /dev/random is just a DoS waiting
>> to happen and user space programmers know that.
>> ...
> 
> If programs just need some random data without relying on the fact that 
> it's cryptographically strong /dev/urandom is the right choice.

No in this case /dev/urandom is the wrong choice. You should seed
then some standard RND with the time,pid as is the classical way
and not use any precious entropy. Yes some programs don't do that,
but they're wrong and actually slightly dangerous.

> But some programs need entropy for doing crypto stuff, and a local DoS 
> is harmless compared to the consequences of bad /dev/random data.

Even the cryptographic programs normally use /dev/urandom to get
session keys etc. That is because they are definitely concerned about
local DoS. Just strace your ssh daemon or your SSL web server to see
what I mean.

> Consider as a worst case the just discovered OpenSSL bug in Debian where 
> all accounts with public key authentification and keys created on a 
> Debian/Ubuntu system during the last 20 months [1] can be taken over by 
> an attacker within less than 20 minutes with a simple brute force 
> attack. [2]

Yes, but if you read the context of that patch it commented out
the code that accessed /dev/urandom!

Please reread my analysis of the issue. If you have already entropy in
the pool  the additional feed doesn't change anything. And if you don't
it still stays the same.

-Andi
