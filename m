From: David Miller <davem@davemloft.net>
Subject: Re: [Devel] [PATCH][NETNS] Move some code into __init section when
 CONFIG_NET_NS=n
Date: Mon, 08 Oct 2007 00:17:16 -0700 (PDT)
Message-ID: <20071008.001716.116377615.davem@davemloft.net>
References: <4704F083.7090203@openvz.org>
	<20071004140202.GA6180@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752538AbXJHHRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 03:17:17 -0400
In-Reply-To: <20071004140202.GA6180@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Thu, 4 Oct 2007 18:02:02 +0400

> On Thu, Oct 04, 2007 at 05:54:11PM +0400, Pavel Emelyanov wrote:
> > With the net namespaces many code leaved the __init section,
> > thus making the kernel occupy more memory than it did before.
> > Since we have a config option that prohibits the namespace
> > creation, the functions that initialize/finalize some netns
> > stuff are simply not needed and can be freed after the boot.
> > 
> > Currently, this is almost not noticeable, since few calls
> > are no longer in __init, but when the namespaces will be
> > merged it will be possible to free more code. I propose to 
> > use the __net_init, __net_exit and __net_initdata "attributes"
> > for functions/variables that are not used if the CONFIG_NET_NS
> > is not set to save more space in memory.
> 
> > +#ifdef CONFIG_NET_NS
> > +#define __net_init
> > +#define __net_exit
> > +#define __net_initdata
> > +#else
> > +#define __net_init	__init
> > +#define __net_exit	__exit
> > +#define __net_initdata	__initdata
> > +#endif
> 
> Yet another set of double-underscored section annotations is the last thing
> that is needed, methinks. :)

I'm not so sure.  I think double-underscores are a powerful deterrant
for developers.  Over time folks have learned that this prefix
in an interface name means "semantics are non-trivial, use with
care" and that definitely applies to init sections.

I'm going to apply Pavel's patch, if you want to touch it up do so
as a followon patch, thanks!

