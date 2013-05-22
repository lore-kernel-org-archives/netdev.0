From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Wed, 22 May 2013 18:28:41 +0800
Message-ID: <1369218521.5097.20.camel@cr0>
References: <1368750099-14086-3-git-send-email-amwang@redhat.com>
	 <20130517.141327.2084320693913331713.davem@davemloft.net>
	 <1369198453.5722.12.camel@cr0>
	 <20130522.001453.864958570289931561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754079Ab3EVK2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 06:28:52 -0400
In-Reply-To: <20130522.001453.864958570289931561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 00:14 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 22 May 2013 12:54:13 +0800
> 
> > Actually that is exactly what I _did_ in v1 or RFC, IIRC, it is David
> > Stevens who prefers to use #ifdef inside these functions, so I changed
> > it based on his suggestion.
> > 
> > I myself don't have any strong opinion here, either is okay, I just
> > don't like changing it again and again. :)
> 
> The driver looks like complete shit with all the ifdefs in there,
> this isn't the BSD kernel.
> 
> I do not want to seem them there at all.
> 
> You can abstract everything behind helper functions in a header
> file, keep the mess there.

Alright, I will change all such functions in vxlan.c back to what you
are suggesting.

For example, change

static inline
bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr
*b)
{
#if IS_ENABLED(CONFIG_IPV6)
       if (a->sa.sa_family != b->sa.sa_family)
               return false;
       if (a->sa.sa_family == AF_INET6)
               return ipv6_addr_equal(&a->sin6.sin6_addr,
&b->sin6.sin6_addr);
       else
#endif
               return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
}

to

#if IS_ENABLED(CONFIG_IPV6)
static inline
bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr
*b)
{
       if (a->sa.sa_family != b->sa.sa_family)
               return false;
       if (a->sa.sa_family == AF_INET6)
               return ipv6_addr_equal(&a->sin6.sin6_addr,
&b->sin6.sin6_addr);
       else
               return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
}
#else
static inline
bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr
*b)
{
	return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
}
#endif

just in case I misunderstand you.

Thanks.
