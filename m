From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static inline
Date: Wed, 22 May 2013 18:50:22 +0300
Message-ID: <CAF1J0HNZS_s9pA1jetaFHZgqdgT+BfS6wASDpTL5UV8SzpH6Fg@mail.gmail.com>
References: <1368750099-14086-3-git-send-email-amwang@redhat.com>
	<20130517.141327.2084320693913331713.davem@davemloft.net>
	<1369198453.5722.12.camel@cr0>
	<20130522.001453.864958570289931561.davem@davemloft.net>
	<1369218521.5097.20.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog104.obsmtp.com ([74.125.245.76]:45108 "HELO
	na3sys010aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756601Ab3EVPuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 11:50:24 -0400
Received: by mail-qc0-f175.google.com with SMTP id a1so1124230qcx.20
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 08:50:23 -0700 (PDT)
In-Reply-To: <1369218521.5097.20.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 1:28 PM, Cong Wang <amwang@redhat.com> wrote:
> On Wed, 2013-05-22 at 00:14 -0700, David Miller wrote:
>> From: Cong Wang <amwang@redhat.com>
>> Date: Wed, 22 May 2013 12:54:13 +0800
>>
>
> Alright, I will change all such functions in vxlan.c back to what you
> are suggesting.
>
> For example, change
>
> static inline
> bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr
> *b)
> {
> #if IS_ENABLED(CONFIG_IPV6)
>        if (a->sa.sa_family != b->sa.sa_family)
>                return false;
>        if (a->sa.sa_family == AF_INET6)
>                return ipv6_addr_equal(&a->sin6.sin6_addr,
> &b->sin6.sin6_addr);
>        else
> #endif
>                return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
> }
>
> to
>
> #if IS_ENABLED(CONFIG_IPV6)
> static inline
> bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr
> *b)
> {
>        if (a->sa.sa_family != b->sa.sa_family)
>                return false;
>        if (a->sa.sa_family == AF_INET6)
>                return ipv6_addr_equal(&a->sin6.sin6_addr,
> &b->sin6.sin6_addr);
>        else
>                return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
> }
> #else
> static inline
> bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr
> *b)
> {
>         return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
> }
> #endif

I think you can just drop #ifdefs in 90% of the cases rather than
create two versions of code for IPv4 and IPv6....

> just in case I misunderstand you.
>
> Thanks.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Sincerely yours,
Mike.
