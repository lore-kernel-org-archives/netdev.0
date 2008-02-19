From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Tue, 19 Feb 2008 15:45:00 +0100
Message-ID: <47BAEB6C.1030609@trash.net>
References: <200801291316.m0TDGivY024953@hera.kernel.org>	 <1203428949.3223.25.camel@shinybook.infradead.org>	 <47BAE13D.4060206@trash.net> <1203431447.3223.33.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:8106 "EHLO
	viefep18-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756771AbYBSOpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 09:45:22 -0500
In-Reply-To: <1203431447.3223.33.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> On Tue, 2008-02-19 at 15:01 +0100, Patrick McHardy wrote:
>> David Woodhouse wrote:
>>>> +union nf_inet_addr {
>>>> +	u_int32_t	all[4];
>>>> +	__be32		ip;
>>>> +	__be32		ip6[4];
>>>> +};
>>>> +
>>>>  #ifdef __KERNEL__
>>>>  #ifdef CONFIG_NETFILTER
>>> This breaks the busybox build:
>>>
>>> CC      ipsvd/tcpudp.o
>>> In file included from /usr/include/linux/netfilter_ipv4.h:8,
>>>                  from ipsvd/tcpudp.c:33:
>>> /usr/include/linux/netfilter.h:40: error: expected specifier-qualifier-list before 'u_int32_t'
>>>
>>> What is this 'u_int32_t' nonsense anyway?
>>>
>>> If a user-visible header is likely to be included by libc directly from
>>> a 'standard' header, it may not require <stdint.h>. Therefore it should
>>> use the system-specific types such as '__u32'.
>> Right, I queued this patch to fix it.
> 
> That does the trick -- but are we using u_int32_t elsewhere in
> user-visible headers? Does it work there? How?


Its used in nearly every ip_tables header file. Those are most likely
not included by glibc and iptables includes sys/types.h. Besides
iptables I'm only aware of a perl module that uses these files,
which is probably also including sys/types.h.

>>> A later commit adds struct in_addr and struct in6_addr to this union
>>> too, which breaks busybox even harder.
>> Thats odd, the iptables headers have always used struct in_addr and
>> struct in6_addr in struct ipt_ip/struct ip6t_ip6, which are also
>> used by userspace. What is "ipsvd/tcpudp.c"? I couldn't find it in
>> the Debian busybox source.
> 
> It's in busybox 1.9.1. Just including <netinet/in.h> seems to be
> sufficient to make it happy again. I wonder if netfilter.h should
> include that for itself?


That would break iptables compilation, which already includes
linux/in.h in some files. I guess the best fix for now is to
include netinet/in.h in busybox and long-term clean this up
properly.


