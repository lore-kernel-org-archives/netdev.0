From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 22 Jul 2015 13:38:31 -0700
Message-ID: <55AFFF47.8040704@cumulusnetworks.com>
References: <20150722.104926.1502608671575195516.davem@davemloft.net> <55AFEF4B.6070702@cumulusnetworks.com> <20150722195706.GA26717@pox.localdomain> <20150722.130444.1245167673786115378.davem@davemloft.net> <20150722201729.GB26717@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36160 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbbGVUid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 16:38:33 -0400
Received: by pdjr16 with SMTP id r16so146740302pdj.3
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 13:38:32 -0700 (PDT)
In-Reply-To: <20150722201729.GB26717@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/22/15, 1:17 PM, Thomas Graf wrote:
> On 07/22/15 at 01:04pm, David Miller wrote:
>> From: Thomas Graf <tgraf@suug.ch>
>> Date: Wed, 22 Jul 2015 21:57:06 +0200
>>
>>> On 07/22/15 at 12:30pm, roopa wrote:
>>>> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
>>>> index 5c467ef..2b28615 100644
>>>> --- a/net/mpls/Kconfig
>>>> +++ b/net/mpls/Kconfig
>>>> @@ -24,6 +24,8 @@ config NET_MPLS_GSO
>>>>
>>>>   config MPLS_ROUTING
>>>>          tristate "MPLS: routing support"
>>>> +       depends on INET
>>>> +       depends on IPV6
>>>>          ---help---
>>>>           Add support for forwarding of mpls packets.
>>> This looks like a much better fix to me and resolves the
>>> module/built-in dependency mess.
>> It's only OK if we don't create a new hard dependency on IPV6,
>> which this patch does.
>>
>> Consitently across the tree we give the user the option of
>> using a bi-AF facility with or without IPV6.
> OK. I guess there is an MPLS routing use case which does not
> depend on INET or IPV6 if all routes specify an RTA_OIF. Not
> enough of an expert to know if that is the common case or not.

yes, there is ie., the kernel supports it. though we have never used it 
nor plan to. Not sure about the use case.
>
> Otherwise I would have argued to start dropping the special status
> for IPv6 and start treating IP dependency as a combination of both
> to promote it further/faster. It can still be explicitly disabled.
> Then again, I might be too optimistic in assuming that this will
> be the year of IPv6 ;-)
:).

I cant think of a way to fix the current problem with my patch....ie, 
when CONFIG_IPV6=m and my module does not have a hard dependency on 
CONFIG_IPV6.
If there are suggestions, pls let me know (I am ok with a revert until 
there is a solution).

I do see ip6_route_output used from several modules, they all quite 
likely have a hard dependency on CONFIG_IPV6.
