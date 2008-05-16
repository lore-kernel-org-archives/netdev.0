From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last
	few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 16:20:49 +0300
Message-ID: <20080516132049.GC8029@cs181133002.pp.htv.fi>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515173939.1ec968be@core> <482C7DA3.1090809@garzik.org> <482C953A.4080205@garzik.org> <87abirytxj.fsf@basil.nowhere.org> <20080516105635.6cb1f505@core> <482D5FC5.2070103@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:58180 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655AbYEPNWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 09:22:37 -0400
Content-Disposition: inline
In-Reply-To: <482D5FC5.2070103@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 12:19:49PM +0200, Andi Kleen wrote:
>...
> The only problem you got from possible bogus input is that the entropy
> counts will be wrong, but in my experience nearly all programs
> use /dev/urandom anyways because /dev/random is just a DoS waiting
> to happen and user space programmers know that.
>...

If programs just need some random data without relying on the fact that 
it's cryptographically strong /dev/urandom is the right choice.

But some programs need entropy for doing crypto stuff, and a local DoS 
is harmless compared to the consequences of bad /dev/random data.

Consider as a worst case the just discovered OpenSSL bug in Debian where 
all accounts with public key authentification and keys created on a 
Debian/Ubuntu system during the last 20 months [1] can be taken over by 
an attacker within less than 20 minutes with a simple brute force 
attack. [2]

> -Andi

cu
Adrian

[1] 13 months for Debian stable users
[2] http://www.derkeiler.com/Mailing-Lists/Full-Disclosure/2008-05/msg00416.html

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

