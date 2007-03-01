From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a
 random value
Date: Thu, 1 Mar 2007 14:54:23 -0800
Message-ID: <20070301145423.6ffc52e5.akpm@linux-foundation.org>
References: <200703011933.l21JX5hw018666@fire-2.osdl.org>
	<20070301143417.00b49e81.akpm@linux-foundation.org>
	<20070301143727.4ba00d04@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, loveminix@yahoo.com.cn,
	khc@pm.waw.pl
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52716 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161116AbXCAWyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 17:54:32 -0500
In-Reply-To: <20070301143727.4ba00d04@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Mar 2007 14:37:27 -0800
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> On Thu, 1 Mar 2007 14:34:17 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 1 Mar 2007 11:33:05 -0800
> > bugme-daemon@bugzilla.kernel.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=8107
> > > 
> > >            Summary: dev->header_cache_update has a random value
> > >     Kernel Version: 2.6.20
> > >             Status: NEW
> > >           Severity: high
> > >              Owner: jgarzik@pobox.com
> > >          Submitter: loveminix@yahoo.com.cn
> > > 
> > > 
> > > Distribution: Kernel 2.6.20
> > > 
> > > Problem Description:
> > > 
> > > In struct net_device, there are two fields: hard_header_cache and 
> > > header_cache_update, both of which are function pointers. The third field, 
> > > hard_header, is also a function pointer. Whenever hard_header points to a valid 
> > > function, both hard_header_cache and header_cache_update should have a known 
> > > value, either NULL or a valid function pointer. However, in 
> > > drivers/net/wan/hdlc_cisco.c, in function static int cisco_ioctl(struct 
> > > net_device *dev, struct ifreq *ifr), where dev->hard_header is assigned a valid 
> > > function, and dev->hard_header_cache is assigned a known value (NULL), dev-
> > > >header_cache_update is not set to a known value:
> > > 
> > > dev->hard_start_xmit = hdlc->xmit;
> > >         dev->hard_header = cisco_hard_header;
> > >         dev->hard_header_cache = NULL;
> > >         dev->type = ARPHRD_CISCO;
> > >         dev->flags = IFF_POINTOPOINT | IFF_NOARP;
> > >         dev->addr_len = 0;
> > > 
> > > This may cause serious problems when dev->header_cache_update is invoked, 
> > > because it has an uninitialized value.
> > > 
> > > Steps to reproduce:
> > > 
> > > I found this suspicious spot with the help of a code-checking tool.
> > > 
> > 
> > Like this?
> 
> Not necessary, since any network device must already allocated by
> alloc_netdev() and it initializes the whole struct to 0 (NULL).

But ioctl(IF_PROTO_CISCO) can be run multiple times across the lifetime of
a net_device?
