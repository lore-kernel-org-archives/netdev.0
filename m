From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: Re: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Thu, 20 Dec 2012 11:14:07 +0400
Message-ID: <50D2BABF.2060402@oktetlabs.ru>
References: <50D1BCC0.2000208@oktetlabs.ru>	 <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com>	 <50D1CECE.7090706@oktetlabs.ru> <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([195.131.132.186]:46077 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750933Ab2LTHOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 02:14:16 -0500
In-Reply-To: <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/12 23:37, Ben Hutchings wrote:
> On Wed, 2012-12-19 at 18:27 +0400, Yurij M. Plotnikov wrote:
>    
>> On 12/19/12 17:35, Ben Hutchings wrote:
>>      
>>> On Wed, 2012-12-19 at 17:10 +0400, Yurij M. Plotnikov wrote:
>>>
>>>        
>>>> On kernel 3.7.1 I get strange behaviour of IP_MTU_DISCOVER socket
>>>> option. The behaviour in case of IP_PMTUDISC_DO and IP_PMTUDISC_WANT
>>>> values of IP_MTU_DISCOVER socket option on SOCK_DGRAM socket are the
>>>> same and packet is always sent with "Don't Fragment" bit in case of
>>>> IP_PMTUDISC_WANT. Also, the value of IP_MTU socket option is not updated.
>>>>
>>>>          
>>> You could try reverting:
>>>
>>> commit ee9a8f7ab2edf801b8b514c310455c94acc232f6
>>> Author: Steffen Klassert<steffen.klassert@secunet.com>
>>> Date:   Mon Oct 8 00:56:54 2012 +0000
>>>
>>>       ipv4: Don't report stale pmtu values to userspace
>>>
>>>       We report cached pmtu values even if they are already expired.
>>>       Change this to not report these values after they are expired
>>>       and fix a race in the expire time calculation, as suggested by
>>>       Eric Dumazet.
>>>
>>> Still, PMTU information is not supposed to expire for 10 minutes...
>>>
>>>
>>>        
>> With reverted commit there is no such problem on 3.7.1: IP_MTU is
>> updated and DF is set only for the first packet in case of
>> IP_PMTUDISC_WANT.
>>      
> [...]
>
> So it looks like something is going wrong with the expiry calculation
> here.
>
> This change shouldn't affect the PMTU actually used by the kernel, but
> could affect Onload since that relies on netlink route updates to keep
> in synch.  You didn't say you were using Onload, but if you are then we
> should not bother netdev with this until we can demonstrate a problem
> that involves only the kernel stack.
>
>    
The results were obtained on pure Linux kernel without using Onload.

Yurij.
