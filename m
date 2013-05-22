From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Wed, 22 May 2013 19:10:14 +0300
Message-ID: <20130522161013.GA10184@zed>
References: <1368750099-14086-3-git-send-email-amwang@redhat.com>
 <20130517.141327.2084320693913331713.davem@davemloft.net>
 <1369198453.5722.12.camel@cr0>
 <20130522.001453.864958570289931561.davem@davemloft.net>
 <1369218521.5097.20.camel@cr0>
 <CAF1J0HNZS_s9pA1jetaFHZgqdgT+BfS6wASDpTL5UV8SzpH6Fg@mail.gmail.com>
 <703447758.6014383.1369238603475.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:49488 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750956Ab3EVQKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 12:10:20 -0400
Received: by mail-ee0-f42.google.com with SMTP id c50so1217601eek.1
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 09:10:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <703447758.6014383.1369238603475.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 12:03:23PM -0400, Cong Wang wrote:
> 
> 
> ----- Original Message -----
> > 
> > I think you can just drop #ifdefs in 90% of the cases rather than
> > create two versions of code for IPv4 and IPv6....
> > 
> 
> I know we can use memcmp(), but comparing 16+ bytes even for IPv4 is not
> a good idea, also we have to zalloc() every instance of union vxlan_addr.

I've lost you here... Why not just:

static inline
bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
{
       if (a->sa.sa_family != b->sa.sa_family)
               return false;
       if (a->sa.sa_family == AF_INET6)
               return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
       else
               return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
}

--
Sincrely yours,
Mike.
