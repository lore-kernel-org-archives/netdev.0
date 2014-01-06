From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Mon, 6 Jan 2014 17:01:39 +0100
Message-ID: <20140106160139.GB10204@order.stressinduktion.org>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us> <20140102172949.GF22494@order.stressinduktion.org> <20140104104331.GB9295@minipsycho.orion> <20140104105515.GA25828@order.stressinduktion.org> <20140104110557.GD9295@minipsycho.orion> <20140104111546.GB25828@order.stressinduktion.org> <1388834511.7407.5.camel@weing> <20140104113543.GC25828@order.stressinduktion.org> <1389022909.23397.4.camel@weing>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42487 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbaAFQBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 11:01:41 -0500
Content-Disposition: inline
In-Reply-To: <1389022909.23397.4.camel@weing>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 04:41:49PM +0100, Thomas Haller wrote:
> On Sat, 2014-01-04 at 12:35 +0100, Hannes Frederic Sowa wrote:
> > On Sat, Jan 04, 2014 at 12:21:51PM +0100, Thomas Haller wrote:
> > > > > >Also, I saw that NetworkManager switched to install autoconf addresses
> > > > > >as /128, doesn't this break with IFA_F_MANAGETEMPADDR, as you expect a /64
> > > > > >prefixlen?
> > > > > 
> > > > > /64 is required
> > > > 
> > > > Ok, currently NM seems to "violate" that as it installs autoconf addresses
> > > > with 128 prefixlen, so IFA_F_MANAGETEMPADDR should not work on them.
> > > > (currently observed on Fedora 20).
> > > 
> > > True, I noticed that too. I think that is a bug in NM to add the
> > > addresses as /128. Probably, we will fix that soon.
> > 
> > The change could be valid. Otherwise currently NM could not correctly handle
> > prefix information in RAs in some cases:
> > 
> > It is possible to let the client generate an autonomously address in a
> > prefix which is actually not on-link (L=0). Kernel would automatically
> > create prefix route by mistake, if NM tries to install such an address
> > with /64 prefix. This does not happen if the prefix address uses 128
> > prefixlen.
> > 
> > Would be great to have feedback on this, as this could be easily solved by an
> > additional ifa_flag.
> > 
> > Greetings,
> > 
> >   Hannes
> > 
> 
> 
> Hi Hannes,
> 
> 
> good point. I think, the user-space application (NetworkManager) should
> add the autoconf addresses as /64. But the kernel should not generate
> any routes in that case. It's up to the application to add them
> (depending on the on-link flag).
> 
> 
> What do you think about something like:

I would introduce a new flag for that and also make it accessible via
iproute, maybe later. Otherwise IFA_F_MANAGETEMPADDR is overloaded and
doesn't do justice to its name. And since Jiri made new room in ifa_flags,
it shoud be no problem. ;)

Btw. while just reviewing anycast changes, I noticed a funny thing:
Kernel does allocate an anycast address which is the same as the autoconf
address, if NM installs /128 address and you have ipv6 forwarding enabled
(fedora 20 install + ipv6 forwarding because of libvirt). You can see the
addresses pop up in /proc/net/anycast6. I currenlty don't know if that
is problematic.  Everything seems to work here for me. ;)

In the end, I don't think we should install anycast for /128, but I am not
sure, yet.

Greetings,

  Hannes
