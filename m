From: Chris Leech <christopher.leech@intel.com>
Subject: Re: [PATCH] net headers: export dcbnl.h
Date: Fri, 27 Feb 2009 10:16:01 -0800
Message-ID: <1235758561.4774.25.camel@cleech-mobl1>
References: <20090227004635.10247.60814.stgit@localhost.localdomain>
	 <20090227055506.GA7020@uranus.ravnborg.org>
	 <20090227.024635.51509388.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "sam@ravnborg.org" <sam@ravnborg.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10312 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918AbZB0SQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 13:16:06 -0500
In-Reply-To: <20090227.024635.51509388.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-02-27 at 02:46 -0800, David Miller wrote:
> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Fri, 27 Feb 2009 06:55:06 +0100
> 
> > On Thu, Feb 26, 2009 at 04:46:35PM -0800, Chris Leech wrote:
> > > The DCB netlink interface is required for building the userspace tools
> > > available at e1000.sourceforge.net
> > 
> > Hmmm, is that file ready for export....
> > 
> > >From dcbnl.h:
> > #ifndef __LINUX_DCBNL_H__
> > #define __LINUX_DCBNL_H__
> > 
> > #define DCB_PROTO_VERSION 1
> > 
> > struct dcbmsg {
> >         unsigned char      dcb_family;
> >         __u8               cmd;
> >         __u16              dcb_pad;
> > };
> > 
> > 1) It uses __u8/__u16 so it would be nice it is included <linux/types.h>
> > so these are actually defined.

OK, I'll send again with a patch to add <linux/types.h>

> > 2) Why does it use "unsigned char" for one member and __u8 for another.
> > It looks inconsistent.

My guess is that the first member was made to be unsigned char to match
struct rtgenmsg, but other rtnetlink users define family as __u8
(fib_rule_hdr, ndmsg, ndtmsg) so it should be OK to change it.

> > We export headers that are much worse but we better raise the bar a little.
> 
> Agreed, we should sort out these issues before exporting.

