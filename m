From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Fri, 08 Aug 2008 10:58:04 -0400
Message-ID: <489C5EFC.6030006@hp.com>
References: <489BCB1A.5040100@cn.fujitsu.com>	<489BE0DA.80306@cn.fujitsu.com> <20080807.230334.239030482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:34663 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbYHHO6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 10:58:08 -0400
In-Reply-To: <20080807.230334.239030482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Yang Hongyang <yanghy@cn.fujitsu.com>
> Date: Fri, 08 Aug 2008 13:59:54 +0800
> 
>> Yang Hongyang wrote:
>>> when I use getsockopt(sk, IPPROTO_IPV6, IPV6_2292PKTOPTIONS,(char *)incmsg, &cnt)
>>> to get receiving interface index while no message is received,
>>>
>>> What interface index should be returned?
>> When get receiving interface index while no message is received,
>> the bounded device's index of the socket should be returned?
>>
>> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
> 
> To me it seems to be an undefined operation.
> 
> One cannot expect something valid from this socket option until a
> packet really is received on the socket.

Here is what 2292 has to say:

>   The corresponding receive option
> 
>        getsockopt(fd, IPPROTO_IPV6, IPV6_PKTOPTIONS, &buf, &len);
> 
>    returns a buffer with one or more ancillary data objects for all the
>    optional receive information that the application has previously
>    specified that it wants to receive.  The fourth argument points to
>    the buffer that is filled in by the call.  The fifth argument is a
>    pointer to a value-result integer: when the function is called the
>    integer specifies the size of the buffer pointed to by the fourth
>    argument, and on return this integer contains the actual number of
>    bytes that were returned.  The application processes this buffer
>    exactly as if the buffer were returned by recvmsg() as control
>    information.


So, there return value should be any sticky options set.

In the case of PKTINFO, the interface should be either 0 or the one
set by the sticky option.

The address should be should be from the options or IN6ADDR_ANY.

This is all for RFC2292 style.

For RFC 3542 style,  there what should be done:

   Issuing getsockopt() for the above options will return the sticky
   option value i.e., the value set with setsockopt().  If no sticky
   option value has been set getsockopt() will return the following
   values:

   -  For the IPV6_PKTINFO option, it will return an in6_pktinfo
      structure with ipi6_addr being in6addr_any and ipi6_ifindex being
      zero.

-vlad
