From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Thu, 09 Jul 2015 23:56:48 -0500
Message-ID: <87wpy84nlb.fsf@x220.int.ebiederm.org>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>
	<559EAD2A.2090002@cumulusnetworks.com>
	<CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>
	<877fq894l8.fsf@x220.int.ebiederm.org>
	<559F29FD.6090705@cumulusnetworks.com>
	<87vbds64z4.fsf@x220.int.ebiederm.org>
	<559F4814.70306@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
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
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45265 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbbGJFC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 01:02:27 -0400
In-Reply-To: <559F4814.70306@cumulusnetworks.com> (David Ahern's message of
	"Thu, 09 Jul 2015 22:20:36 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 7/9/15 9:55 PM, Eric W. Biederman wrote:
>>> IP addresses are per interface and interfaces are uniquely assigned to
>>> a VRF so why do you think IP addresses are not per VRF?
>>
>> I have read large swaths of the linux networking code over the years.
>>
>> Further I was thinking more about non-local addresses ip addresses, but
>> I would not be surprised if there are also issues with local addresses.
>
> Well, if someone has a specific example I'll take a look.

I have given specific areas of concern, and explained myself and you are
blowing me off.

Besides the fragment reassembly and xfrm there are things like the
ineetpeer cache.

>>>>   Which means things like packet fragmentation reassembly
>>>> can easily do the wrong thing.  Similarly things like the xfrm for ipsec
>>>> tunnels are not hooked into this mix.
>>>>
>>>> So I really do not see how this VRF/MRF thing as designed can support
>>>> general purpose sockets.  I am not certain it can correctly support any
>>>> kind of socket except perhaps SOCK_RAW.
>>>
>>> Sockets bound to the VRF device work properly. Why do you think they won't?
>>
>> Because there are many locations in the network stack (like fragment
>> reassembly) that make the assumption that ip addresses are unique and
>> do not bother looking at network device or anything else.  If fragments
>> manage to come into play I don't expect it would be hard to poision a
>> connections with fragments from another routing domain with overlapping
>> ip addresses.
>
> If that is true it is a problem with the networking stack today and is
> completely independent of this VRF proposal.

Not at all.  It is required functionality for reassembly of ip fragments
when the packets come in via different paths.  This is required to
support multi-path ip reception.

This only becomes a bug in the scenario you have proposed.

Eric
