From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created
 with no group
Date: Wed, 19 Mar 2014 18:29:00 -0400 (EDT)
Message-ID: <20140319.182900.467525569537111207.davem@davemloft.net>
References: <CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>
	<20140319.154649.1043650085697557640.davem@davemloft.net>
	<CAF1J0HPT3u05uu6uLYDDu7cV11Ku6AHVooSLLAoaYj6wVtfemA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbaCSW3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 18:29:04 -0400
In-Reply-To: <CAF1J0HPT3u05uu6uLYDDu7cV11Ku6AHVooSLLAoaYj6wVtfemA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Wed, 19 Mar 2014 21:52:31 +0200

> On Wed, Mar 19, 2014 at 9:46 PM, David Miller <davem@davemloft.net> wrote:
>> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
>> Date: Wed, 19 Mar 2014 09:14:46 +0200
>>
>>> On Tue, Mar 18, 2014 at 10:55:16AM -0600, David Stevens wrote:
>>>>
>>>> Wouldn't it be better to:
>>>>
>>>> 1) make sure all of vxlan_dev is initialized before use,
>>>> especially default_dst
>>>> 2) change the v6 code to check for AF_INET6 too, and do
>>>> nothing if not set. If not set by the admin, the family of
>>>> default_dst would then be AF_UNSPEC and not match.
>>>
>>> The family of default dst is implicitly initailized to AF_UNSPEC because
>>> if kzalloc :)
>>>
>>> I agree that explicit check for AF_INET6 is much better than fallthrough
>>> with simple 'else' clause and I can send a patch that makes the checks
>>> for IPv6 as well as default_dst initialization explicit
>>>
>>> However, for the particular case in vxlan_rcv, checking the packet
>>> version seems to me semantically more correct than comparing default_dst
>>> protocol family with AF_INET or AF_INET6.
>>
>> The way I read things, we would receive packets unconditionally in the
>> pre-ipv6-support code.  So we have to keep doing so.
>>
>> Therefore we either have to check the SKB protocol or pass an explicit
>> protocol as an argument to vs->rcv(...).
> 
> Well, the patch I've sent checks for ip_hdr(skb) protocol version...

Yes, I know.

I'm just going to wait and see if anyone else in this thread
has anything more to say.
