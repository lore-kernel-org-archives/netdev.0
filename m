From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel
 found
Date: Thu, 02 Nov 2006 16:22:07 +0200
Message-ID: <4549FF0F.6020705@tcs.hut.fi>
References: <4549D8E7.1040409@tcs.hut.fi>	<20061102.215900.15793371.yoshfuji@linux-ipv6.org>	<4549EFA7.50004@tcs.hut.fi> <20061102.231810.119656005.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:7052 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1750735AbWKBOWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 09:22:15 -0500
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <20061102.231810.119656005.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/06 16:18, YOSHIFUJI Hideaki wrote:
> In article <4549EFA7.50004@tcs.hut.fi> (at Thu, 02 Nov 2006 15:16:23 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> 
>> On 11/02/06 14:59, YOSHIFUJI Hideaki wrote:
>>> In article <4549D8E7.1040409@tcs.hut.fi> (at Thu, 02 Nov 2006 13:39:19 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
>>>
>>>>  	read_unlock(&ip6ip6_lock);
>>>> -	return 1;
>>>> -
>>>> +	icmpv6_send(skb, ICMPV6_DEST_UNREACH,
>>>> +		    ICMPV6_ADDR_UNREACH, 0, skb->dev);
>>>>  discard:
>>> I'd argue this.  We probably should not send back any ICMPv6 packets 
>>> to the original sender in this case to avoid DoS.
>> Sorry, I don't follow you. I don't see the DoS scenario here (after we
>> apply the patch, that is ;-).
> 
> Well, leaving aside whether sending icmpv6 is good thing (*),
> the code for sending icmpv6 was moved from ip6_tunnel.c
> to tunnel6.c by commit-id 50fba2aa7cefa6b0e1768cb350c9e69042320c03
> by Herbert.
> 
> The ip6_tunnel.c change that Herbert made does not seem consistent
> with ipip.c change.  To fix your issue the appropriate change is just
> fall through to discard section, as we're doing for ipip.c.
> 
> Please do not re-add sending icmpv6 logic here.
> If you DO think it is appropriate, please fix other codes
> such as ipip.c, and your comment.

Ok, I'll resubmit a patch doesn't send an ICMPv6 error message.

Regards,
Ville
