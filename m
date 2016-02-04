From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v5 2/2] virtio_net: add ethtool support for set
 and get of settings
Date: Thu, 4 Feb 2016 14:23:14 +0200
Message-ID: <20160204142156-mutt-send-email-mst@redhat.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-3-git-send-email-razor@blackwall.org>
 <56B1C608.1040805@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56865 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755732AbcBDMXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 07:23:18 -0500
Content-Disposition: inline
In-Reply-To: <56B1C608.1040805@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 10:19:04AM +0100, Nikolay Aleksandrov wrote:
> On 02/03/2016 04:04 AM, Nikolay Aleksandrov wrote:
> > From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> > 
> > This patch allows the user to set and retrieve speed and duplex of the
> > virtio_net device via ethtool. Having this functionality is very helpful
> > for simulating different environments and also enables the virtio_net
> > device to participate in operations where proper speed and duplex are
> > required (e.g. currently bonding lacp mode requires full duplex). Custom
> > speed and duplex are not allowed, the user-supplied settings are validated
> > before applying.
> > 
> > Example:
> > $ ethtool eth1
> > Settings for eth1:
> > ...
> > 	Speed: Unknown!
> > 	Duplex: Unknown! (255)
> > $ ethtool -s eth1 speed 1000 duplex full
> > $ ethtool eth1
> > Settings for eth1:
> > ...
> > 	Speed: 1000Mb/s
> > 	Duplex: Full
> > 
> > Based on a patch by Roopa Prabhu.
> > 
> > Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> > ---
> > v2: use the new ethtool speed/duplex validation functions and allow half
> > duplex to be set
> > v3: return error if the user tries to change anything besides speed/duplex
> > as per Michael's comment
> > We have to zero-out advertising as it gets set automatically by ethtool if
> > setting speed and duplex together.
> > v4: Set port type to PORT_OTHER
> > v5: null diff1.port because we set cmd->port now and ethtool returns it in
> > the set request, retested all cases
> > 
> 
> Hmm, nulling the advertising and ->port completely ignores them, i.e. won't produce
> an error if the user actually specified a different value for either of them.
> We can check if the ->port matches what we returned, but there's no fix for
> advertising. I'm leaving both ignored for now, please let me know if you'd
> prefer otherwise.
> 
> Thanks,
>  Nik

I think I prefer validating port.
For advertising we don't allow enabling autonegotiation so ignoring
these is fine I think.

-- 
MST
