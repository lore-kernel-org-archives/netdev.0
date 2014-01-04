From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Sat, 4 Jan 2014 12:35:43 +0100
Message-ID: <20140104113543.GC25828@order.stressinduktion.org>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us> <20140102172949.GF22494@order.stressinduktion.org> <20140104104331.GB9295@minipsycho.orion> <20140104105515.GA25828@order.stressinduktion.org> <20140104110557.GD9295@minipsycho.orion> <20140104111546.GB25828@order.stressinduktion.org> <1388834511.7407.5.camel@weing>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38686 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaADLfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 06:35:44 -0500
Content-Disposition: inline
In-Reply-To: <1388834511.7407.5.camel@weing>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 12:21:51PM +0100, Thomas Haller wrote:
> > > >Also, I saw that NetworkManager switched to install autoconf addresses
> > > >as /128, doesn't this break with IFA_F_MANAGETEMPADDR, as you expect a /64
> > > >prefixlen?
> > > 
> > > /64 is required
> > 
> > Ok, currently NM seems to "violate" that as it installs autoconf addresses
> > with 128 prefixlen, so IFA_F_MANAGETEMPADDR should not work on them.
> > (currently observed on Fedora 20).
> 
> True, I noticed that too. I think that is a bug in NM to add the
> addresses as /128. Probably, we will fix that soon.

The change could be valid. Otherwise currently NM could not correctly handle
prefix information in RAs in some cases:

It is possible to let the client generate an autonomously address in a
prefix which is actually not on-link (L=0). Kernel would automatically
create prefix route by mistake, if NM tries to install such an address
with /64 prefix. This does not happen if the prefix address uses 128
prefixlen.

Would be great to have feedback on this, as this could be easily solved by an
additional ifa_flag.

Greetings,

  Hannes
