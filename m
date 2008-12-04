From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Thu, 04 Dec 2008 10:00:47 +0100
Message-ID: <1228381247.3197.16.camel@Friederike-PC.hoffi>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <1227783281.3809.78.camel@johannes.berg>
	 <200812021807.25873.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47009 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbYLDJBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 04:01:32 -0500
In-Reply-To: <200812021807.25873.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-02 at 18:07 -0800, Inaky Perez-Gonzalez wrote:

> For scanning, some devices require to be told exactly where to scan in
> (as in which combination of band, fft width and coloring of the
> band). Some others don't. 

But things like these are fairly easy to cover, just allow netlink
attributes to specify where to scan, and allow drivers to disregard
them, no harm caused. Maybe include a capability bit, like I'm adding to
nl80211 in my scanning patch (not included yet) that includes a
capability for how many SSIDs it can scan actively at once.

> Then of course, the scan results might be
> operators? Network Service Providers? Network Access Providers?  base
> station IDs? how do you stitch'em together? You need information to
> map from one to the other, and that is device specific depending on at
> which level they work. How to stich that information together depends
> on the network too (OMA-DM and provisining information help to compose
> this). If it is done at the device/firmware level or at the host level
> is device specific.

I have no idea about these things, obviously. But what's wrong with just
defining the scan operation with netlink attributes as you need them now
(say the scan returns NSPs) and then later when somebody needs to return
NAPs add a new attribute? Userspace will easily be able to figure out
which one it got by looking at which attributes are present.

> Connect has exactly the same levels of issues as scan: what do I
> connect to? A base station? a NAP or an NSP?
> 
> So back to the original question: I have no information to define such
> an interface at low level, so I am not defining it. Simple :/

Here's where I disagree, obviously, I think you should at least define a
subset of the imaginable interface, which is, in my opinion, _much_
better than defining no interface at all and hoping for the next guy to
figure it out, which is unlikely to happen when you haven't started with
something the next guy can understand.

> > This really means you're putting the actual "driver", the piece that
> > does the hardware abstraction, into userspace. And in a binary daemon
> > even, afaict. This was quickly shot down with ipw3945/4965, not sure why
> > nobody has cared here so far. Maybe because you're actually planning to
> > open source that part.
> 
> Nope. I am putting the part that knows how to scan and connect in user 
> space because it does not belong in kernel space. It is big and complex, 
> needs permanent storage, requires complex crypto code and can really
> use a OMA-DM client to communicate with the network.

Ok, I guess that makes sense then, I'm not aware of all the details.

> Not a binary, btw. Currently the supplicant is a binary, but that will
> change. The OMA-DM client daemon is also a binary as of now and we
> are still thinking how to fix that situation, as there are no open
> source equivalents. Luckily, it is kind of optional.

Ok, thanks for the explanation.

johannes

