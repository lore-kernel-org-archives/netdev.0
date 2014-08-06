From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: IPv6 over IEEE 802.15.4 aka 6LoWPAN - Neighbor discovery issue
Date: Wed, 06 Aug 2014 12:45:27 +0530
Message-ID: <53E1D60F.3090602@gmail.com>
References: <20140805121516.GB14196@omega> <53E1B912.5000508@gmail.com> <20140806071025.GA29810@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-wpan@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40432 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbaHFHQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 03:16:59 -0400
In-Reply-To: <20140806071025.GA29810@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2014 12:40 PM, Alexander Aring wrote:
> Hi Varka,
>
> On Wed, Aug 06, 2014 at 10:41:46AM +0530, Varka Bhadram wrote:
>> The 6LoWPAN Neighbor Discovery protocol (RFC6775) is an optimized version of the
>> standard IPv6 Neighbor Discovery protocol. 6LoWPAN-ND  uses the same standard
>> ND (RFC4861) messages (ICMPv6) with some additional options (ARO , 6CO and ABRO).
>> Two new messages (DAR and DAC) have been added to consider the support of Neighbor Discovery
>> for bootstrapping, header compression, mobility, fault tolerance, etc.
>>
>> We implemented 6LoWPAN-ND for linux kernel 3.12, which handles ARO option
>> in NS(Neighbour Solicitation) and sends NA (Neighbour Advertisement) with
>> updated ARO option as per RFC6775. We may send you the patches for this implementation.
>> And we implemented handling of DAR and DAC.
>>
> Did you have solve the issue between short and extended address? For
> RFC6775 we need also context based address compression, we don't support
> this mainline right now.

We only supported extended address. We did not include the context based
address compression.

>
> If yes then you can send me these patches.
>
>> Handing of RS (Router Solicitation) and RA (Router Advertisement) will take care
>> by radvd (Router Advertisement Daemon) in Linux. We added the ABRO and 6CO option
>> support in radvd. You can find the implementation in [1].
>>
>>
>> [1]: https://github.com/reubenhwk/radvd/blob/master/send.c#L536
>>
> I see you use the ContextID there, then you need the CID value from
> 6LoWPAN header there. I am very interest for patches which introduce
> context based address compression and make it also available in
> userspace to handle the ContextID with radvd.

Right now we providing the contextID from user space through radvd.conf.

Context based implementation is not supported so we are only using the
context identifier from user space.

> Thanks.
>
> - Alex

-- 
Regards,
Varka Bhadram.
