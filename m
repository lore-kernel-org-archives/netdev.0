From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Thu, 09 Jul 2015 22:55:59 -0500
Message-ID: <87vbds64z4.fsf@x220.int.ebiederm.org>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>
	<559EAD2A.2090002@cumulusnetworks.com>
	<CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>
	<877fq894l8.fsf@x220.int.ebiederm.org>
	<559F29FD.6090705@cumulusnetworks.com>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:40442 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbbGJEBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 00:01:38 -0400
In-Reply-To: <559F29FD.6090705@cumulusnetworks.com> (David Ahern's message of
	"Thu, 09 Jul 2015 20:12:13 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 7/9/15 7:36 PM, Eric W. Biederman wrote:
>> Sowmini Varadhan <sowmini05@gmail.com> writes:
>>
>>> On Thu, Jul 9, 2015 at 7:19 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>>
>>>> On the to-do list to use cmsg to specify a VRF for outbound packets using
>>>> non-connected sockets. I do not believe it is going to work, but need to
>>>> look into it.
>>>>
>>>>> What about setting ipsec policy for interfaces in the vrf?
>>>
>>>  From a purely parochial standpoint, how would rds sockets work in this model?
>>> Would the tcp encaps happen before or after the the vrf "driver" output?
>>> Same problem for NFS.
>>>
>>>  From a non-parochial standpoint. There are a *lot* of routing apps that actually
>>> need more visibility into many details about the "slave" interface: e.g., OSPF,
>>> ARP snoop, IPSLA.. the list is pretty long.
>>>
>>> I think it's a bad idea to use a "driver" to represent a table lookup. Too many
>>> hacks will become necessary.
>>
>> With respect to sockets there is also the issue that ip addresses are
>> not per vrf.
>
> IP addresses are per interface and interfaces are uniquely assigned to
> a VRF so why do you think IP addresses are not per VRF?

I have read large swaths of the linux networking code over the years.

Further I was thinking more about non-local addresses ip addresses, but
I would not be surprised if there are also issues with local addresses.

>>  Which means things like packet fragmentation reassembly
>> can easily do the wrong thing.  Similarly things like the xfrm for ipsec
>> tunnels are not hooked into this mix.
>>
>> So I really do not see how this VRF/MRF thing as designed can support
>> general purpose sockets.  I am not certain it can correctly support any
>> kind of socket except perhaps SOCK_RAW.
>
> Sockets bound to the VRF device work properly. Why do you think they won't?

Because there are many locations in the network stack (like fragment
reassembly) that make the assumption that ip addresses are unique and
do not bother looking at network device or anything else.  If fragments
manage to come into play I don't expect it would be hard to poision a
connections with fragments from another routing domain with overlapping
ip addresses.

I guess if we are talking about SO_BINDTODEVICE which requires
CAP_NET_RAW we aren't really talking ordinary applications so there is
already a big helping of buyer beware.

Still a blanket statement that sockets just work and there is nothing
to be concerned about is just wrong.

Eric
