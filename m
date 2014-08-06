From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: IPv6 over IEEE 802.15.4 aka 6LoWPAN - Neighbor discovery issue
Date: Wed, 06 Aug 2014 14:02:40 +0530
Message-ID: <53E1E828.2050706@gmail.com>
References: <20140805121516.GB14196@omega> <53E1B912.5000508@gmail.com> <20140806071025.GA29810@omega> <53E1D60F.3090602@gmail.com> <20140806074715.GA31022@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-wpan@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:60752 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817AbaHFIeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 04:34:11 -0400
In-Reply-To: <20140806074715.GA31022@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2014 01:17 PM, Alexander Aring wrote:
>>>> Handing of RS (Router Solicitation) and RA (Router Advertisement) will take care
>>>> by radvd (Router Advertisement Daemon) in Linux. We added the ABRO and 6CO option
>>>> support in radvd. You can find the implementation in [1].
>>>>
>>>>
>>>> [1]: https://github.com/reubenhwk/radvd/blob/master/send.c#L536
>>>>
>>> I see you use the ContextID there, then you need the CID value from
>>> 6LoWPAN header there. I am very interest for patches which introduce
>>> context based address compression and make it also available in
>>> userspace to handle the ContextID with radvd.
>> Right now we providing the contextID from user space through radvd.conf.
>>
>> Context based implementation is not supported so we are only using the
>> context identifier from user space.
>>
> A static CID value in radvd.conf? Sorry, I don't know how this can be
> working without very limitations of use.

Actually we have to get the CID from the 6LoWPAN packet and we have to
update or store the CID based information into a separate table.

For each and every CID we are going to have the its own info.

If CID is changed we have to increment the *version* field in ABRO option
and sends RA message. This support is future work if we have the CID based
compression.


-- 
Regards,
Varka Bhadram.
