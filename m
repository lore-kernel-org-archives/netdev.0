From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Fri, 10 Jul 2015 12:42:35 -0600
Message-ID: <55A0121B.8090408@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>	<559EAD2A.2090002@cumulusnetworks.com>	<CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>	<877fq894l8.fsf@x220.int.ebiederm.org>	<559F29FD.6090705@cumulusnetworks.com>	<87vbds64z4.fsf@x220.int.ebiederm.org>	<559F4814.70306@cumulusnetworks.com> <87wpy84nlb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini05@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37851 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933107AbbGJSmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 14:42:38 -0400
Received: by igpy18 with SMTP id y18so19309715igp.0
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 11:42:38 -0700 (PDT)
In-Reply-To: <87wpy84nlb.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/9/15 10:56 PM, Eric W. Biederman wrote:
> I have given specific areas of concern, and explained myself and you are
> blowing me off.

You have not had answered my question with any additional details or 
code references -- ie., a specific example. Asking you for clarification 
and details is not blowing you off.

To recap:

Eric: "With respect to sockets there is also the issue that ip addresses 
are not per vrf."

David: "IP addresses are per interface and interfaces are uniquely 
assigned to a VRF so why do you think IP addresses are not per VRF?"

Eric: "I have read large swaths of the linux networking code over the 
years. Further I was thinking more about non-local addresses ip 
addresses, but I would not be surprised if there are also issues with 
local addresses."

David: "Well, if someone has a specific example I'll take a look."

So, let me try this again: All of the IPv4 and IPv6 addresses I am aware 
of are held in structs linked to a specific netdevice. Can you give me a 
specific example of what you mean here? I can't respond to your feedback 
based on the little information you have given me.

>
> Besides the fragment reassembly and xfrm there are things like the
> ineetpeer cache.

noted.

>
>>>>>    Which means things like packet fragmentation reassembly
>>>>> can easily do the wrong thing.  Similarly things like the xfrm for ipsec
>>>>> tunnels are not hooked into this mix.
>>>>>
>>>>> So I really do not see how this VRF/MRF thing as designed can support
>>>>> general purpose sockets.  I am not certain it can correctly support any
>>>>> kind of socket except perhaps SOCK_RAW.
>>>>
>>>> Sockets bound to the VRF device work properly. Why do you think they won't?
>>>
>>> Because there are many locations in the network stack (like fragment
>>> reassembly) that make the assumption that ip addresses are unique and
>>> do not bother looking at network device or anything else.  If fragments
>>> manage to come into play I don't expect it would be hard to poision a
>>> connections with fragments from another routing domain with overlapping
>>> ip addresses.
>>
>> If that is true it is a problem with the networking stack today and is
>> completely independent of this VRF proposal.
>
> Not at all.  It is required functionality for reassembly of ip fragments
> when the packets come in via different paths.  This is required to
> support multi-path ip reception.
>
> This only becomes a bug in the scenario you have proposed.

Can you please point to a specific line in one of these patches that 
impacts fragmentation?

This patch -- patch 3 -- adds a VRF driver. It has not mucked with 
packets at all.

Patch 4 (again I have a better split in a forthcoming revision) tweaks a 
few places in the IPv4 stack with respect to socket lookups (dif 
modified) and FIB table lookups (specifying a table to use or tweaking 
oif/iif).

Since the VRF device has not touched the packet and does not introduce a 
tunnel how has its use/existence impacted fragmentation?

I do plan tests to include ipsec for example and fragmentation; it's a 
matter of time. If you have suggestions on a setup/test case I should 
include please let me know.

David
