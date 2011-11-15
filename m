From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next] enable virtio_net to return bus_info in
 ethtool -i consistent with emulated NICs
Date: Tue, 15 Nov 2011 00:10:38 +0000
Message-ID: <1321315839.2827.25.camel@bwh-desktop>
References: <20111114215241.5B8BF2900307@tardy>
	 <1321309800.2827.22.camel@bwh-desktop>  <4EC1ACF6.9060908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <raj@tardy.cup.hp.com>, <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Michael Tsirkin <mst@redhat.com>,
	<virtualization@lists.linux-foundation.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3204 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab1KOAKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 19:10:46 -0500
In-Reply-To: <4EC1ACF6.9060908@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 16:06 -0800, Rick Jones wrote:
> On 11/14/2011 02:30 PM, Ben Hutchings wrote:
> > On Mon, 2011-11-14 at 13:52 -0800, Rick Jones wrote:
> >> From: Rick Jones<rick.jones2@hp.com>
> >>
> >> Add a new .bus_name to virtio_config_ops then modify virtio_net to
> >> call through to it in an ethtool .get_drvinfo routine to report
> >> bus_info in ethtool -i output which is consistent with other
> >> emulated NICs and the output of lspci.
> > [...]
> >> diff --git a/drivers/lguest/lguest_device.c b/drivers/lguest/lguest_device.c
> >> index 0dc30ff..3724d45 100644
> >> --- a/drivers/lguest/lguest_device.c
> >> +++ b/drivers/lguest/lguest_device.c
> >> @@ -381,6 +381,11 @@ error:
> >>   	return PTR_ERR(vqs[i]);
> >>   }
> >>
> >> +static const char *lg_bus_name(struct virtio_device *vdev)
> >> +{
> >> +	return "Not Implemented";
> >> +}
> > [...]
> >> +static const char *kvm_bus_name(struct virtio_device *vdev)
> >> +{
> >> +	return "Not Implemented";
> >> +}
> > [...]
> >
> > Please use the existing 'not implemented' value, which is the empty
> > string.   If you think ethtool should print some helpful message instead
> > of an empty string, please submit a patch for ethtool.
> 
> 
> One question - will those actually be called via an ethtool path?  In my 
> poking about through the virtio code, I got the impression those modules 
> were for "other than networking" sorts of things.

I don't know; I just assumed that was why you were adding them!  In
other contexts such as dev_printk() this string would make even less
sense.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
