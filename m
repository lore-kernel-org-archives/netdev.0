From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Mon, 01 Apr 2013 13:02:23 -0400 (EDT)
Message-ID: <20130401.130223.1527520446382659798.davem@davemloft.net>
References: <1364708625-29063-1-git-send-email-amwang@redhat.com>
	<1364708625-29063-3-git-send-email-amwang@redhat.com>
	<OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, stephen@networkplumber.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758389Ab3DARCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 13:02:25 -0400
In-Reply-To: <OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Mon, 1 Apr 2013 11:19:10 -0400

> netdev-owner@vger.kernel.org wrote on 03/31/2013 01:43:44 AM:
>  
>> +struct vxlan_ip {
>> +   union {
>> +      __be32  ip4;
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +      struct in6_addr ip6;
>> +#endif
>> +   };
>> +   __be16          proto;
>> +};
>> +
> 
>         This looks suspiciously like a sockaddr. sockaddr_storage is
> much bigger than you need, but you could just make it a sockaddr_in6
> and cast it to sockaddr_in when needed, make it sockaddr_in6 and use
> V4_MAPPED addresses for v4, or make it a union of sockaddr_in and
> sockaddr_in6, or have a buffer the size of sockaddr_in6 and use it
> as a sockaddr to determine the family, then go from there.
>         I think anything along those lines is better than a new variant
> with the same functionality of sockaddr that isn't an overlay of a
> sockaddr.

People avoid using sockaddr because it gets defined both in the kernel
exported userland headers and the native libc ones with no easy
protection between the two to avoid getting a double definition error.

Once you start including kernel exported headers for things like these
network device specific interfaces, you potentially run into that issue.

Therefore I'd rather the subsystem define their own unique type both
to avoid this double definition problem and to allow easy extention
later.
