From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Wed, 06 Dec 2006 23:40:50 -0800 (PST)
Message-ID: <20061206.234050.77634656.davem@davemloft.net>
References: <456FB283.9090904@miyazawa.org>
	<20061206203537.2e5ba9ec.kazunori@miyazawa.org>
	<20061206.233749.122048397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33062
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031810AbWLGHki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 02:40:38 -0500
To: kazunori@miyazawa.org
In-Reply-To: <20061206.233749.122048397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 06 Dec 2006 23:37:49 -0800 (PST)

> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> Date: Wed, 6 Dec 2006 20:35:37 +0900
> 
> > Sorry, I mixed up changes in the patches. I described that [4/7] will add
> > "IPv6 over IPv4 IPsec tunnel". However I send a patch for "IPv4 over IPv6"
> > as a reply because it includes the discussing item.
> > So this patch adds IPv4 over IPv6 IPsec tunnel. It's complicated.
> > 
> > I deleted subustituting NULL for rt->peer and moved atomic_inc stuff
> > under the "if" section.
> 
> I have applied this patch, thanks for fixing it up.

Actually, I have to revert this change again, it still has a problem.
Sorry :-/

I very much feared the following kind of obstacle with these changes.
Specifically, references to modular IPV6 code from statically compiled
IPV4 code.  Which produces the following build error:

net/built-in.o: In function `__xfrm4_bundle_create':xfrm4_policy.c:(.text+0x59a88): undefined reference to `xfrm6_output'
:xfrm4_policy.c:(.text+0x59ac0): undefined reference to `xfrm6_output'

Please test with IPV6 built modular in the future, thank you.
