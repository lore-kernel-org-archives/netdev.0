From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Subject: Re: [PATCH -tip] in6.h: extern's make no sense in userspace
Date: Tue, 13 Jan 2009 12:50:03 +0530
Message-ID: <1231831203.3212.21.camel@jaswinder.satnam>
References: <1231829859.3212.19.camel@jaswinder.satnam>
	 <20090113071513.GB20036@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, harvey.harrison@gmail.com,
	gorcunov@gmail.com, roque@di.fc.ul.pt,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52918 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757550AbZAMHXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 02:23:09 -0500
In-Reply-To: <20090113071513.GB20036@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-13 at 08:15 +0100, Sam Ravnborg wrote:
> On Tue, Jan 13, 2009 at 12:27:39PM +0530, Jaswinder Singh Rajput wrote:
> > Impact: fix 2 make headers_check warnings:
> > 
> >  usr/include/linux/in6.h:47: extern's make no sense in userspace
> >  usr/include/linux/in6.h:49: extern's make no sense in userspace
> > 
> > Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> > ---
> >  include/linux/in6.h |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/include/linux/in6.h b/include/linux/in6.h
> > index bc49204..718bf21 100644
> > --- a/include/linux/in6.h
> > +++ b/include/linux/in6.h
> > @@ -44,11 +44,11 @@ struct in6_addr
> >   * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
> >   * in network byte order, not in host byte order as are the IPv4 equivalents
> >   */
> > +#ifdef __KERNEL__
> >  extern const struct in6_addr in6addr_any;
> >  #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
> >  extern const struct in6_addr in6addr_loopback;
> >  #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
> > -#ifdef __KERNEL__
> 
> It looks wrong what IN6ADDR_ANY_INIT should be a kernel only symbol.
> At least google had some hits on that symbol.
> 
> netdev people should know....
> 

OK, I do not want any conflicts and I want to stay in safe side ;-)

Subject: [PATCH] in6.h: extern's make no sense in userspace

Impact: fix 2 make headers_check warnings:

 usr/include/linux/in6.h:47: extern's make no sense in userspace
 usr/include/linux/in6.h:49: extern's make no sense in userspace

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 include/linux/in6.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index bc49204..44d921c 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -44,11 +44,11 @@ struct in6_addr
  * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
  * in network byte order, not in host byte order as are the IPv4 equivalents
  */
-extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
-extern const struct in6_addr in6addr_loopback;
 #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
 #ifdef __KERNEL__
+extern const struct in6_addr in6addr_any;
+extern const struct in6_addr in6addr_loopback;
 extern const struct in6_addr in6addr_linklocal_allnodes;
 #define IN6ADDR_LINKLOCAL_ALLNODES_INIT	\
 		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
-- 
1.5.6.6



