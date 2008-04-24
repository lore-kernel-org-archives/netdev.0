From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Thu, 24 Apr 2008 01:49:56 -0700 (PDT)
Message-ID: <20080424.014956.94335109.davem@davemloft.net>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
	<20080424.010845.257071066.davem@davemloft.net>
	<20080424.171644.106117727.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48738
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751131AbYDXIt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:49:57 -0400
In-Reply-To: <20080424.171644.106117727.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Apr 2008 17:16:44 +0900 (JST)

> In article <20080424.010845.257071066.davem@davemloft.net> (at Thu, 24 Apr 2008 01:08:45 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> > Date: Thu, 24 Apr 2008 17:02:57 +0900 (JST)
> > 
> > > +#ifdef __KERNEL__
> > > +struct __compat_sockaddr_storage {
> > > +	unsigned short  ss_family;
> > > +	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
> > > +} __attribute__ ((aligned(4)));
> > > +#endif
> > 
> > Should include <linux/compat.h>, use compat types, and be guarded
> > by CONFIG_COMPAT.  This goes for all such structures.
> 
> Do you mean, something like this?
> 
> #ifdef __KERNEL__
> #include <linux/compat.h>
> 
> #ifdef CONFIG_COMPAT
> struct __compat_sockaddr_storage {
>    unsigned short  ss_family;
>   char            __data[_K_SS_MAXSIZE - sizeof(unsigned short)];
>  __attribute__ ((aligned(alignof(compat_uptr_t))));
> #endif
> #endif

I think first of all that ((packed)) is a better attribute to use than
the explicit alignment.

I thought we had a compat_ushort_t, but we don't.  So I guess you
can avoid the compat.h include, but you do need the CONFIG_COMPAT
guard.
