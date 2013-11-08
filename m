From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Fri, 08 Nov 2013 13:55:24 +0100
Message-ID: <527CDF3C.5060308@6wind.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>	<1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>	<20131107112549.GP31491@secunet.com> <20131107.181723.1978438697370768133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	saurabh.mohan@vyatta.com, sergei.shtylyov@cogentembedded.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37193 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756872Ab3KHMz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 07:55:28 -0500
Received: by mail-wi0-f180.google.com with SMTP id ey11so2117465wid.1
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 04:55:27 -0800 (PST)
In-Reply-To: <20131107.181723.1978438697370768133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 11/08/2013 12:17 AM, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 7 Nov 2013 12:25:49 +0100
>
>> On Wed, Nov 06, 2013 at 09:05:53AM +0100, Christophe Gouault wrote:
>>> The vti interface inbound and outbound SPD lookups are based on the
>>> ipsec packet instead of the plaintext packet.
>>>
>>> Not only is it counterintuitive, it also restricts vti interfaces
>>> to a single policy (whose selector must match the tunnel local and
>>> remote addresses).
>>>
>>> The policy selector is supposed to match the plaintext packet, before
>>> encryption or after decryption.
>>>
>>> This patch performs the SPD lookup based on the plaintext packet. It
>>> enables to create several polices bound to the vti interface (via a
>>> mark equal to the vti interface okey).
>>>
>>> It remains possible to apply the same policy to all packets entering
>>> the vti interface, by setting an any-to-any selector (src 0.0.0.0/0
>>> dst 0.0.0.0/0 proto any mark OKEY).
>>>
>>> Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
>> Hm, this patch breaks my current vti test setup. I would need to
>> configure the policies and states dependent on the kernel version
>> if we apply this patch...
>>
>> It would be good to hear from the original author of the vti code
>> whether the current behaviour is intentional before we do anything
>> here.
> I'm disappointed that we're breaking IPSEC semantics several times.
> This really isn't acceptable at all, not even remotely.
I understand your disappointment, however this patch precisely aims at 
*restoring* theIPsec semantics:
the original vti code uses the SP selector to match the ipsec encrypted 
packetinstead of the plaintext packet, which is contrary to the IPsec 
semantics.
> The fact that a developer has a configuration he was actually
> using, and would be broken by this patch, says to me that there
> is absolutely no way I can apply this.
As wrote Steffen Klassert, it would be good to hear from the original 
author ofthe vti code (Saurabh Mohan) whether the current behaviour is 
intentional.

It would also be good to know how many people currently use vti, but my 
feeling is that vti is still at an experimental stage.

Best Regards,
Christophe
> Sorry.
