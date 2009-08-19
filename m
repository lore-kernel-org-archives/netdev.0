From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH V2] lib/vsprintf.c: Add struct sockaddr * "%pN<foo>" output
Date: Wed, 19 Aug 2009 19:00:53 -0400
Message-ID: <D496D39A-A657-42DC-A4E2-4020E0E54398@oracle.com>
References: <1250230925.6641.92.camel@fnki-nb00130> <20090814.001519.40499255.davem@davemloft.net> <1250237739.16632.12.camel@fnki-nb00130> <20090814.131218.139318801.davem@davemloft.net> <1250349894.4620.5.camel@Joe-Laptop.home> <1250395818.4625.15.camel@Joe-Laptop.home> <2D3306C4-4DF4-4E3E-BBC2-2032058FA673@oracle.com> <1250714657.3407.77.camel@Joe-Laptop.home> <6EE37F10-4354-49FE-9FF1-BB38BDD10E6E@oracle.com> <1250721391.3407.103.camel@Joe-Laptop.home>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jens@mcbone.net, brian.haley@hp.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:23895 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbZHSXBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 19:01:35 -0400
In-Reply-To: <1250721391.3407.103.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Aug 19, 2009, at 6:36 PM, Joe Perches wrote:
> On Wed, 2009-08-19 at 18:20 -0400, Chuck Lever wrote:
>> On Aug 19, 2009, at 4:44 PM, Joe Perches wrote:
>>> I'm not too sure there's much value in ever more formatters for
>>> relatively simple things or in printing something like port or
>>> scope without the ip address.
>>>
>>> %hu ntohs(sa6->sin6_port)
>>> or
>>> %d or 0x%x ntohl(sa6->sin6_flowinfo)
>>>
>>> seem pretty straightforward to me.
>>
>> It's the same issue for port numbers as it is for addresses: though
>> the port field is the same size in each, it's at different offsets in
>> AF_INET and AF_INET6 addresses, so extra logic is still needed to  
>> sort
>> that at each call site.

I should add that the scope ID and flowinfo tag are IPv6 only, so they  
really don't have the same problem.  If you have to print a scope ID,  
you pretty much know you are dealing only with sockaddr_in6.

>> As an example, an rpcbind query cares about the port number result,
>> but usually not the address.  A human-readable message could show the
>> returned port number, but leave out the address.  Without a separate
>> formatter, you would still need extra logic around each debugging
>> message (for example) to choose how to print the port number.
>>
>> You could probably argue, though, that this is a less common need  
>> than
>> printing addresses.
>
> I suppose an address exclude could be added to %pN
> if really needed.  Maybe "%pNx(specifiers)"

>>> Here's another tentative patch that does both using square
>>> brackets around IPv6 addresses with a port number and
>>> allows selection of the port number style ":dddd" or ":hi.lo"
>>
>> The "hi.lo" form is always separated from the address by a dot, not  
>> by
>> a colon, and square brackets are never used in that case.  The hi.lo
>> format is probably enough of a special case that a separate specifier
>> for that one is unnecessary.
>
> Is the RPC code never used with a ipv6_addr_v4mapped address?
> ::192.168.0.1.1.1 would look pretty ugly

As I understand it, TI-RPC does not ever use mapped v4 addresses on  
the wire (only pure IPv4 and IPv6).  So they shouldn't actually appear  
in the universal address format, in practice.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
