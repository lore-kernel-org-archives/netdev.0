From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Thu, 21 Sep 2006 14:30:46 +0900 (JST)
Message-ID: <20060921.143046.29082693.yoshfuji@linux-ipv6.org>
References: <20060919.000800.127570535.yoshfuji@linux-ipv6.org>
	<20060918185746.GD18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:24583 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751235AbWIUF2f
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 01:28:35 -0400
To: tgraf@suug.ch
In-Reply-To: <20060918185746.GD18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20060918185746.GD18349@postel.suug.ch> (at Mon, 18 Sep 2006 20:57:46 +0200), Thomas Graf <tgraf@suug.ch> says:

> * YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> 2006-09-19 00:08
:
> >     [NET]: Include new rtnetlink headers for userspace backward compatibility.
:
> > diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> > index 3a18add..8ec375c 100644
> > --- a/include/linux/rtnetlink.h
> > +++ b/include/linux/rtnetlink.h
> > @@ -2,7 +2,12 @@ #ifndef __LINUX_RTNETLINK_H
> >  #define __LINUX_RTNETLINK_H
> >  
> >  #include <linux/netlink.h>
> > +#ifndef __KERNEL__
> > +/* Backward compatibility */
> >  #include <linux/if_link.h>
> > +#include <linux/if_addr.h>
> > +#include <linux/neighbour.h>
> > +#endif
> >  
> >  /****
> >   *		Routing/neighbour discovery messages.
> 
> Still acceptable but this gets ugly at some point. Applications using
> the interface should start making copies of the header version they
> use.

I understand, but I feel it is more ugly.

> > commit 55a08a9078b243a06223222735580df9e11a5fa6
> > Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > Date:   Sun Sep 17 13:55:02 2006 +0900
> > 
> >     [NET]: Put {IFLA,IFA,NDA,NDTA}_{RTA,PAYLOAD}() macro back.
> >     
> >     These macros are still used by userspace applications.
> 
> Same here, it doesn't make sense to export macros only of functional
> value and used by userspace only. The same issue will pop up once
> all users have been converted to use the new netlink interface.
> Keeping the old interface around just so userspace doesn't have to
> make copies doesn't make sense. I think it's better to start fixing
> userspace than to try and keep headers source compatible.

Backward compatibility is one of the most important factor.
A careless breakage is, say,  of "brain freeze."

About these macros, we have other similar *_{RTA,PAYLOAD}()s in kernel,
which are not used by kernel but are exported to userspace.  They are
forming part of our API, and they're good example how to use netlink
interface.

Yes, we could change the interface, but we definately need to give
them graceful period at least; we can do it in 2.7, or at least,
after 2-3 stable releases.

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
