From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Sun, 18 Oct 2015 19:29:45 -0700 (PDT)
Message-ID: <20151018.192945.1549146309693737023.davem@davemloft.net>
References: <20151016.010644.2090038835491896678.davem@davemloft.net>
	<20151016100221.6fd5034f@griffin>
	<56211E6D.4070507@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, tgraf@suug.ch
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbbJSCN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 22:13:28 -0400
In-Reply-To: <56211E6D.4070507@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 16 Oct 2015 09:57:33 -0600

> On 10/16/15 2:02 AM, Jiri Benc wrote:
>> On Fri, 16 Oct 2015 01:06:44 -0700 (PDT), David Miller wrote:
>>> No, it's definitely not OK, because lwtunnel support exists in
>>> Linus's tree.
>>>
>>> And tools should be able to work on all kernels where lwtunnel support
>>> is available.
>>
>> You can consider the lwtunnels feature as not finished in the current
>> Linus's tree. It works, it won't change (thus anything using it in its
>> current form will continue to work in all the future kernels), but
>> mainstream tools won't make use of it until a kernel version later
>> which will get some additional support.
>>
>> I don't think it's much of a problem and I don't think it is the first
>> time this would happen.
>>
>> I'm afraid I don't have any solution that could do better.
> 
> What about a flag that requests the version from the relevant kernel
> subsystem?

The whole point of having an easily extensible protocol like netlink
with attributes and whatnot was to avoid messy schemes like
versioning.

The big mistake was ignoring unknown attributes.  I mean seriously,
think about it, what if the new attribute specified by the user was
some security setting or something?  I'm sure even more dangerous
examples can be imagined.

I'm beginning to wonder if we can just change this unilaterally to
not ignore unrecognized attributes.

I am increasingly certain that things that would "break" we wouldn't
want to succeed anyways.
