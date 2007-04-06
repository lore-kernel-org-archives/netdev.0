From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/4] [IPv6] Add link and site-local scope inline
Date: Fri, 06 Apr 2007 02:37:52 -0400
Message-ID: <4615EAC0.3080709@hp.com>
References: <11758281863002-git-send-email-brian.haley@hp.com>	<4615BCA1.6000608@hp.com> <20070406.122433.60252840.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dccp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim03.cce.hp.com ([161.114.21.24]:31327 "EHLO
	ccerelrim03.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605AbXDFGh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 02:37:56 -0400
In-Reply-To: <20070406.122433.60252840.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



YOSHIFUJI Hideaki / ???? wrote:
> In article <4615BCA1.6000608@hp.com> (at Thu, 05 Apr 2007 23:21:05 -0400), Brian Haley <brian.haley@hp.com> says:
> 
>> Add link and site-local scope inline to avoid calls to ipv6_addr_type().
>>
> 
> I disagree.  Multicast scopes should also be handled appropriately.

Yes, I totally missed that 
ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)) in __ipv6_addr_type(), so 
the linklocal inline probably isn't worth it since it would have to be 
something like:

static inline int ipv6_addr_scope_linklocal(const struct in6_addr *a)
{
return ((a->s6_addr32[0] & htonl(0xFFC00000)) == htonl(0xFE800000) ||
         ((a->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000) &&
          ((a)->s6_addr[1] & 0x0f) == IPV6_ADDR_SCOPE_LINKLOCAL)))
}

That's not that clean an inline anymore, but still doable...

I'll clean-up the rest based on your comments and re-send.

-Brian
