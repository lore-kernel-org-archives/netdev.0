From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Wed, 19 Dec 2007 14:14:40 -0500
Message-ID: <47696DA0.7060003@hp.com>
References: <OF367F9F64.87ED9167-ON882573B6.0063B893-882573B6.0064BE22@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:1894 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786AbXLSTOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 14:14:43 -0500
In-Reply-To: <OF367F9F64.87ED9167-ON882573B6.0063B893-882573B6.0064BE22@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Vlad Yasevich <vladislav.yasevich@hp.com> wrote on 12/19/2007 07:20:53 AM:
> 
>> But this still requires either a SO_BINDTODEVICE or sin6_scope_id.  This
>> means the an application can call BINDTODEVICE(eth0), MULTICAST_IF(eth1)
>> issue a connect on a UDP socket an succeed?  Seems wrong to me.
>>
>> Can you check section 6.7 of RFC 3542.
> 
>         No, it requires one of SO_BINDTODEVICE, sin6_scope_id, or 
> IPV6_MULTICAST_IF.
> If you do an SO_BINDTODEVICE(eth0) and then an IPV6_MULTICAST_IF(eth1), 
> the
> IPV6_MULTICAST_IF will fail in setsockopt (EINVAL), because it requires a 
> match
> for bound sockets. I'm not sure if SO_BINDTODEVICE resets mcast_oif if you 
> do
> them in the reverse order, but that would be a bug in SO_BINDTODEVICE.

It doesn't, that was one way I tested my first patch by forcing a mis-match.

>         The precedence order as implemented already is:
> 
>                 SO_BINDTODEVICE is highest and always wins
>                 sin6_scope_id next
>                 IPV6_MULTICAST_IF
> 
> and the existing code has the rule that all link-local addresses require a
> sin6_scope_id. The change (intended) is to relax the sin6_scope_id rule 
> only
> for link-local multicasts that have done either an SO_BINDTODEVICE or
> IPV6_MULTICAST_IF already.

Yes, that was the intention of my patch.

-Brian
