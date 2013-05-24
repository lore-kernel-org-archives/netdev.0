From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Fri, 24 May 2013 13:15:20 +0800
Message-ID: <1369372520.5590.2.camel@cr0>
References: <1368750099-14086-3-git-send-email-amwang@redhat.com>
	 <20130517.141327.2084320693913331713.davem@davemloft.net>
	 <1369198453.5722.12.camel@cr0>
	 <20130522.001453.864958570289931561.davem@davemloft.net>
	 <1369218521.5097.20.camel@cr0>
	 <CAF1J0HNZS_s9pA1jetaFHZgqdgT+BfS6wASDpTL5UV8SzpH6Fg@mail.gmail.com>
	 <703447758.6014383.1369238603475.JavaMail.root@redhat.com>
	 <20130522161013.GA10184@zed>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752685Ab3EXFPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 01:15:39 -0400
In-Reply-To: <20130522161013.GA10184@zed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 19:10 +0300, Mike Rapoport wrote:
> I've lost you here... Why not just:
> 
> static inline
> bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
> {
>        if (a->sa.sa_family != b->sa.sa_family)
>                return false;
>        if (a->sa.sa_family == AF_INET6)
>                return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
>        else
>                return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
> }

I see your point now, but for !CONFIG_IPV6, the first two 'if' is
obviously useless. Is GCC smart enough to know ->sa.sa_family ==
AF_INET4 is always true in such case? I doubt...
