From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: ipv6_addr_type() and mapped IPv4 loopback
Date: Tue, 4 Nov 2008 11:44:59 -0500
Message-ID: <443B1A57-9994-4555-BCE6-B66B8F406DA2@oracle.com>
References: <06930890-5BC3-4BE2-97CC-B3F6DF33B794@oracle.com> <490FB460.2010501@hp.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet14.oracle.com ([148.87.113.126]:55650 "EHLO
	rgminet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169AbYKDQqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 11:46:11 -0500
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rgminet14.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id mA4GkbwQ026734
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 16:46:38 GMT
In-Reply-To: <490FB460.2010501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian-

On Nov 3, 2008, at Nov 3, 2008, 9:33 PM, Brian Haley wrote:
> Chuck Lever wrote:
>> The __ipv6_addr_type() function does not recognize the mapped IPv4  
>> loopback address:
>>   ::ffff:7f00:0001
>> as type IPV6_ADDR_LOOPBACK.  Is this intentional?
>
> I would think that since the IPv6 loopback address is ::1, and ipv4- 
> mapped is ::ffff:* that this would be IPV6_ADDR_MAPPED.  That's what  
> RFC 4291 seems to say.

So the answer to my original question is then "yes, this is  
intentional," correct?

On a system with an AF_INET6 listener, legacy applications use  
127.0.0.1 to contact a local listener.  The incoming source address  
will be ::ffff:7f00:0001, not ::1.  This means IPv6-enabled  
applications have to perform a separate check for ::ffff:7f00:0001 if  
they are looking for loopback addresses.

The kernel's lockd must verify that an NLM request comes from the  
local user space.  It's not a lot of extra logic, but it is a subtlety.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
