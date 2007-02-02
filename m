From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 02 Feb 2007 17:05:14 -0500
Message-ID: <45C3B59A.6010802@hp.com>
References: <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net> <45C3ACE1.8010800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>,
	sri@us.ibm.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:53382 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946113AbXBBWFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 17:05:17 -0500
In-Reply-To: <45C3ACE1.8010800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Haley wrote:
> Hi Neil,
> 
>> @@ -830,7 +836,8 @@ retry:
>>      ift = !max_addresses ||
>>            ipv6_count_addresses(idev) < max_addresses ?         
>> ipv6_add_addr(idev, &addr, tmp_plen,
>> -                  ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
>> IFA_F_TEMPORARY) : NULL;
>> +                  ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
>> +                  IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
> 

Hi Brian

> So why are you always adding these as optimistic now?  Shouldn't this be
> triggering off idev->cnf.optimistic_dad?  I know you're clearing it in
> ipv6_add_addr(), but I liked Vlad's suggestion of not setting it
> initially since this way seems backwards.

The troubling case seems to manually configured addresses (inet6_addr_add()).
If we can clearly and easily distinguish between this case of address
and all the other ones, then we can simply set the flag in ipv6_add_addr, like
we set the tentative flag.

So, we can introduce another parameter to ipv6_add_addr() or another flag that
can distinguish manual config.  Otherwise, we can keep the code as is, passing
the optimistic flag from needed callers, and clearing it inside ipv6_add_addr().

My thought was to clear it from the 'flags' parameter before ifa->flags was
set, but that  doesn't really matter.

-vlad
