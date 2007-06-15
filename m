From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Fri, 15 Jun 2007 11:20:29 +0200
Message-ID: <467259DD.7030703@hartkopp.net>
References: <20070614081607.GA22931@gondor.apana.org.au> <20070614.130358.90120374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	koster@debian.org.tw, socketcan@hartkopp.net,
	urs@isnogud.escape.de, florz@florz.de
To: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:17349 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbXFOJVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 05:21:06 -0400
In-Reply-To: <20070614.130358.90120374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hallo David, hello Herbert,

indeed i have some concerns about reverting the patch as i do not see
that the MTU is the right thing to distinguish whether a netdevice is
capable to have IPv4/IPv6. E.g. is decnet able to run IPv6?

IMHO the autoconf (in any case) should only handle netdevices that are
capable to be auto configured (e.g. with IPv6).

So the question looks like:
"Is this device capable to be auto configured with IPv6?"
and not
"Is the devices MTU >= IPV6_MIN_MTU ?"

My original patch showed the way to ask the (IMO) correct question. And
maybe this has to be improved somehow (like Florian Zumbiel suggested).
And also maybe the  Autoconfiguration has to be a part of code that is
independent from net/ipv6. But to ask about the MTU size does not look
the right way to me.

Best regards,
Oliver

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 14 Jun 2007 18:16:07 +1000
>
>   
>> [IPV6] addrconf: Fix IPv6 on tuntap tunnels
>>
>> The recent patch that added ipv6_hwtype is broken on tuntap tunnels.
>> Indeed, it's broken on any device that does not pass the ipv6_hwtype
>> test.
>>
>> The reason is that the original test only applies to autoconfiguration,
>> not IPv6 support.  IPv6 support is allowed on any device.  In fact,
>> even with the ipv6_hwtype patch applied you can still add IPv6 addresses
>> to any interface that doesn't pass thw ipv6_hwtype test provided that
>> they have a sufficiently large MTU.  This is a serious problem because
>> come deregistration time these devices won't be cleaned up properly.
>>
>> I've gone back and looked at the rationale for the patch.  It appears
>> that the real problem is that we were creating IPv6 devices even if the
>> MTU was too small.  So here's a patch which fixes that and reverts the
>> ipv6_hwtype stuff.
>>
>> Thanks to Kanru Chen for reporting this issue.
>>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>>     
>
> Thanks for fixing this up Herbert.
>
> Patch applied.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   


