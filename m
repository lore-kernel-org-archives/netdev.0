From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Thu, 07 Nov 2013 13:55:33 +0100
Message-ID: <527B8DC5.6080702@6wind.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com> <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com> <20131107112549.GP31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:42073 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab3KGMzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 07:55:42 -0500
Received: by mail-wg0-f46.google.com with SMTP id m15so466366wgh.13
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 04:55:40 -0800 (PST)
In-Reply-To: <20131107112549.GP31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Steffen,

I am also interested in knowing Saurabh's intentions regarding the 
behavior of policies bound to vti interfaces.

However, please note that setting a policy with a wildcard selector 
works in both cases (before or after this patch), so a common test case 
can be defined.

Actually the *previous* patch on vti (7263a5187f9e vti: get rid of nf 
mark rule in prerouting) introduced significant changes, and implies 
behaviors dependant on the kernel version, but it seemed to meet 
Saurabh's agreement, as the following thread witnesses:

http://www.spinics.net/lists/netdev/msg253134.html

Best Regards,
Christophe

On 11/07/2013 12:25 PM, Steffen Klassert wrote:
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
> Hm, this patch breaks my current vti test setup. I would need to
> configure the policies and states dependent on the kernel version
> if we apply this patch...
>
> It would be good to hear from the original author of the vti code
> whether the current behaviour is intentional before we do anything
> here.
