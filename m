From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] veth: move veth.h to include/linux
Date: Tue, 25 Dec 2007 17:14:15 -0800
Message-ID: <20071225171415.7b7cfc56@deepthought>
References: <20071221094336.63600b8c@deepthought>
	<20071224.220527.254578945.davem@davemloft.net>
	<20071225124656.723c2db6@deepthought>
	<20071225222335.GA5927@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vgusev@openvz.org,
	netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37181 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbXLZBPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Dec 2007 20:15:11 -0500
In-Reply-To: <20071225222335.GA5927@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Dec 2007 23:23:35 +0100
Sam Ravnborg <sam@ravnborg.org> wrote:

> On Tue, Dec 25, 2007 at 12:46:56PM -0800, Stephen Hemminger wrote:
> > Move veth.h from net/ to linux/ since it is a user api, and
> > add it to user header processing Kbuild.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > --- a/drivers/net/veth.c	2007-12-25 12:30:56.000000000 -0800
> > +++ b/drivers/net/veth.c	2007-12-25 12:31:38.000000000 -0800
> > @@ -15,7 +15,7 @@
> >  
> >  #include <net/dst.h>
> >  #include <net/xfrm.h>
> > -#include <net/veth.h>
> > +#include <linux/veth.h>
> >  
> >  #define DRV_NAME	"veth"
> >  #define DRV_VERSION	"1.0"
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ b/include/linux/veth.h	2007-10-16 16:48:20.000000000 -0700
> > @@ -0,0 +1,12 @@
> > +#ifndef __NET_VETH_H_
> > +#define __NET_VETH_H_
> > +
> > +enum {
> > +	VETH_INFO_UNSPEC,
> > +	VETH_INFO_PEER,
> > +
> > +	__VETH_INFO_MAX
> > +#define VETH_INFO_MAX	(__VETH_INFO_MAX - 1)
> > +};
> > +
> > +#endif
> > --- a/include/net/veth.h	2007-12-25 12:33:49.000000000 -0800
> > +++ /dev/null	1970-01-01 00:00:00.000000000 +0000
> > @@ -1,12 +0,0 @@
> > -#ifndef __NET_VETH_H_
> > -#define __NET_VETH_H_
> > -
> > -enum {
> > -	VETH_INFO_UNSPEC,
> > -	VETH_INFO_PEER,
> > -
> > -	__VETH_INFO_MAX
> > -#define VETH_INFO_MAX	(__VETH_INFO_MAX - 1)
> > -};
> > -
> > -#endif
> > --- a/include/linux/Kbuild	2007-12-25 12:44:59.000000000 -0800
> > +++ b/include/linux/Kbuild	2007-12-25 12:45:31.000000000 -0800
> > @@ -342,6 +342,7 @@ unifdef-y += unistd.h
> >  unifdef-y += usbdevice_fs.h
> >  unifdef-y += user.h
> >  unifdef-y += utsname.h
> > +unifdef-y += veth.h
> >  unifdef-y += videodev2.h
> >  unifdef-y += videodev.h
> >  unifdef-y += virtio_config.h
> 
> Someone will argue that you should use header-y +=
> because the file has no conditionals removed by unifdef.
> 
> My personal opinion is that we should kill header-y and
> I had patches to greatly improve all this but they got 
> lost by accident and I have not yet redone them.
> 
> 	Sam

Someone might add kernel code later...

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
