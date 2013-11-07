From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Thu, 07 Nov 2013 18:17:23 -0500 (EST)
Message-ID: <20131107.181723.1978438697370768133.davem@davemloft.net>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
	<1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
	<20131107112549.GP31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe.gouault@6wind.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, saurabh.mohan@vyatta.com,
	sergei.shtylyov@cogentembedded.com, eric.dumazet@gmail.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164Ab3KGXR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 18:17:28 -0500
In-Reply-To: <20131107112549.GP31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 7 Nov 2013 12:25:49 +0100

> On Wed, Nov 06, 2013 at 09:05:53AM +0100, Christophe Gouault wrote:
>> The vti interface inbound and outbound SPD lookups are based on the
>> ipsec packet instead of the plaintext packet.
>> 
>> Not only is it counterintuitive, it also restricts vti interfaces
>> to a single policy (whose selector must match the tunnel local and
>> remote addresses).
>> 
>> The policy selector is supposed to match the plaintext packet, before
>> encryption or after decryption.
>> 
>> This patch performs the SPD lookup based on the plaintext packet. It
>> enables to create several polices bound to the vti interface (via a
>> mark equal to the vti interface okey).
>> 
>> It remains possible to apply the same policy to all packets entering
>> the vti interface, by setting an any-to-any selector (src 0.0.0.0/0
>> dst 0.0.0.0/0 proto any mark OKEY).
>> 
>> Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
> 
> Hm, this patch breaks my current vti test setup. I would need to
> configure the policies and states dependent on the kernel version
> if we apply this patch...
> 
> It would be good to hear from the original author of the vti code
> whether the current behaviour is intentional before we do anything
> here.

I'm disappointed that we're breaking IPSEC semantics several times.
This really isn't acceptable at all, not even remotely.

The fact that a developer has a configuration he was actually
using, and would be broken by this patch, says to me that there
is absolutely no way I can apply this.

Sorry.
