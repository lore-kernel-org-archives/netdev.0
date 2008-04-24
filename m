From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Thu, 24 Apr 2008 17:16:44 +0900 (JST)
Message-ID: <20080424.171644.106117727.yoshfuji@linux-ipv6.org>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
	<20080424.010845.257071066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33445 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbYDXIQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:16:46 -0400
In-Reply-To: <20080424.010845.257071066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080424.010845.257071066.davem@davemloft.net> (at Thu, 24 Apr 2008 01:08:45 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Thu, 24 Apr 2008 17:02:57 +0900 (JST)
> 
> > +#ifdef __KERNEL__
> > +struct __compat_sockaddr_storage {
> > +	unsigned short  ss_family;
> > +	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
> > +} __attribute__ ((aligned(4)));
> > +#endif
> 
> Should include <linux/compat.h>, use compat types, and be guarded
> by CONFIG_COMPAT.  This goes for all such structures.

Do you mean, something like this?

#ifdef __KERNEL__
#include <linux/compat.h>

#ifdef CONFIG_COMPAT
struct __compat_sockaddr_storage {
   unsigned short  ss_family;
  char            __data[_K_SS_MAXSIZE - sizeof(unsigned short)];
 __attribute__ ((aligned(alignof(compat_uptr_t))));
#endif
#endif

> Where is ip6_mc_compat_msfget() header file declaration?
> 
> This following call casts the 5th argument to "struct group_filter"
> but the argument type in the implementation is...

I'll fix...

> Thanks for doing this work, please make corrections and I also
> look forward to your ipv4 side fixes.

Will do.

--yoshfuji
