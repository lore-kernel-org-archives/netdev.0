From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [iproute2 patch]: Add 'ip tuntap' facility for managing
 tun/tap devices
Date: Sat, 13 Jun 2009 09:55:25 +0100
Message-ID: <1244883325.3468.39.camel@macbook.infradead.org>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	 <1241433778.6126.90.camel@macbook.infradead.org>
	 <20090527215823.343abbbe@nehalam>
	 <1243498369.18507.83.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51573 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174AbZFMIz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 04:55:27 -0400
In-Reply-To: <1243498369.18507.83.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-05-28 at 09:12 +0100, David Woodhouse wrote:
> On Wed, 2009-05-27 at 21:58 -0700, Stephen Hemminger wrote:
> > > +#define TUNDEV "/dev/net/tun"
> > 
> > I know this is historical legacy, but how does this play with
> network namespaces?
> 
> For /dev/net/tun itself, it doesn't need to. The namespaces come into
> play when you issue the TUNSETIFF ioctl to create/attach a particular
> named device, which uses the network namespace of the process which
> opened /dev/net/tun.
>  
> > > +static int tap_add_ioctl(struct ifreq *ifr, uid_t uid, gid_t gid)
> > > +{
> > > +   int fd = open(TUNDEV, O_RDWR);
> > > +   int ret = -1;
> > > +
> > > +#ifndef IFF_TUN_EXCL
> > > +#define IFF_TUN_EXCL       0x8000
> > > +#endif
> > 
> > This shouldn't be here.
> > It should be defined in include/linux/if_tun.h in kernel source
> > and then a kernel sanitized version of if_tun.h should be put
> > in iproute2 source for backwards compatibility.
> 
> I'm happy to do that; I was just taking my lead from the handling of
> RTAX_RTTVAR, IP_DF, IPPROTO_SCTP, IPPPROTO_DCCP and IPPROTO_MH in
> ip/*.c
> 
> >  But why bother it doesn't seem to be defined or used by current
> kernel??
> 
> It's in net-next and is harmless in older kernels. It just means you
> can't accidentally 'create' a device which already existed.
> 
> > Would prefer open() next to the test.
> 
> OK, moved.
> 
> > > +     while (argc > 0) {
> > > +             if (strcmp(*argv, "mode") == 0) {
> > 
> > The argument parsing in ip commands uses matches() rather than
> strcmp
> > to allow for partial completion.  
> 
> OK. I had copied that part from 'ip tunnel', which uses strcmp().
> 
> New patch...

Ping?

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

