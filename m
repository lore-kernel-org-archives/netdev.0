From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Thu, 24 Apr 2008 18:28:34 +0900 (JST)
Message-ID: <20080424.182834.104940176.yoshfuji@linux-ipv6.org>
References: <20080424.010845.257071066.davem@davemloft.net>
	<20080424.171644.106117727.yoshfuji@linux-ipv6.org>
	<20080424.014956.94335109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33455 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbYDXJ2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 05:28:37 -0400
In-Reply-To: <20080424.014956.94335109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080424.014956.94335109.davem@davemloft.net> (at Thu, 24 Apr 2008 01:49:56 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Thu, 24 Apr 2008 17:16:44 +0900 (JST)
> 
> > In article <20080424.010845.257071066.davem@davemloft.net> (at Thu, 24 Apr 2008 01:08:45 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> > 
> > > From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> > > Date: Thu, 24 Apr 2008 17:02:57 +0900 (JST)
> > > 
> > > > +#ifdef __KERNEL__
> > > > +struct __compat_sockaddr_storage {
> > > > +	unsigned short  ss_family;
> > > > +	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
> > > > +} __attribute__ ((aligned(4)));
> > > > +#endif
> > > 
> > > Should include <linux/compat.h>, use compat types, and be guarded
> > > by CONFIG_COMPAT.  This goes for all such structures.
> > 
> > Do you mean, something like this?
> > 
> > #ifdef __KERNEL__
> > #include <linux/compat.h>
> > 
> > #ifdef CONFIG_COMPAT
> > struct __compat_sockaddr_storage {
> >    unsigned short  ss_family;
> >   char            __data[_K_SS_MAXSIZE - sizeof(unsigned short)];
> >  __attribute__ ((aligned(alignof(compat_uptr_t))));
> > #endif
> > #endif
> 
> I think first of all that ((packed)) is a better attribute to use than
> the explicit alignment.

Well, I don't think so.

Most (if not all) compat_XXX{} do not have such attribute,
and sockaddr_storage{} shuould actually be aligned on 32bit on
32bit archs, so I think we should declare, no?

For example, if we have
    struct foobar {
        char a;
        struct sockaddr_storage b;
    };
Then, offsetof(struct foobar, b) should be 4, not 1 nor 2.
(Of course all other fields of group_xxx structures are of
u32 here, so it is safe so far...)

Or, are you worrying about alignment of short?

--yoshfuji
