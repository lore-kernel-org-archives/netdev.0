From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: what's in a bus_info
Date: Fri, 4 Nov 2011 17:07:05 -0700
Message-ID: <20111104170705.0553b8cf@nehalam.linuxnetplumber.net>
References: <4EB466CB.2040506@hp.com>
	<1320447726.2753.30.camel@bwh-desktop>
	<4EB475CC.1000601@hp.com>
	<1320450167.2753.39.camel@bwh-desktop>
	<4EB47DB1.2000005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, mst@redhat.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60399 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab1KEAHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 20:07:07 -0400
In-Reply-To: <4EB47DB1.2000005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Nov 2011 17:05:05 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> On 11/04/2011 04:42 PM, Ben Hutchings wrote:
> > On Fri, 2011-11-04 at 16:31 -0700, Rick Jones wrote:
> 
> >> I guess that wraps back around to the question of whether there is a
> >> "standard" for what should be in bus_info.  And if it is impractical to
> >> get the PCI bus information,
> >
> > I'm not that familiar with virtio, but would I be right in thinking that
> > the virtio 'bus' device is likely to be the child of a PCI device?  So
> > then you mgiht want to get bus_name() for the grandparent of the net
> > device:
> > 	dev_dev = dev->dev.parent->parent;
> > (possibly checking for nulls).
> 
> I'll take a look.
> 
> > If there's some reasonable way to distinguish a 'real' from a virtual
> > bus then we could have the generic implementation try to follow parents
> > until it finds a bus device.  However I think the device model
> > maintainers have been gradually moving away from the bus/class
> > distinction and so we may not be able to do that.
> >
> >> whether it is better to return virtioN or
> >> ethN.  Or perhaps something else entirely.
> > [...]
> >
> > Returning the device name seems entirely unhelpful since the user
> > already has that.  'virtioN' is perhaps not much better though.
> 
> Agreed, but thought I should ask :)

My view of bus_info, is that it is an informational string for administrators.
Tools shouldn't depend on the value.  If a tool wants to find out about
the physical device, then it should readlink the value of /sys/class/net/ethX/device
