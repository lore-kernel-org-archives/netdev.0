From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [Q] How to invalidate ARP cache for a network device from
 within kernel
Date: Sat, 27 Nov 2010 16:19:07 +0100
Message-ID: <20101127161907.791a3b7c@stein>
References: <1290793099.3716.21.camel@maxim-laptop>
	<20101127021833.328e8942@stein>
	<1290821143.4145.3.camel@maxim-laptop>
	<20101127093342.3f1d01ce@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux1394-devel <linux1394-devel@lists.sourceforge.net>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:38660 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547Ab0K0PTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 10:19:21 -0500
In-Reply-To: <20101127093342.3f1d01ce@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 27 Stefan Richter wrote:
> > @@ -1593,10 +1593,15 @@ static void fwnet_update(struct fw_unit
> > *unit) {
> >  	struct fw_device *device = fw_parent_device(unit);
> >  	struct fwnet_peer *peer = dev_get_drvdata(&unit->device);
> > +	struct fwnet_device *dev = peer->dev;
> >  	int generation;
> >  
> >  	generation = device->generation;
> >  
> > +	fw_iso_context_stop(dev->broadcast_rcv_context);
> > +	fw_iso_context_start(dev->broadcast_rcv_context, -1, 0,
> > +			FW_ISO_CONTEXT_MATCH_ALL_TAGS);
[...]
> OTOH, is this actually necessary on normal bus resets?  It should only
> be necessary after PM resume, right?  If so, perhaps do it only if the
> generation increased by more than one.

Actually, shouldn't context restart at resume happen in firewire-ohci
rather?  Any other protocol driver which uses isochronous I/O (be it a
kernel driver or userspace driver) would have the same issue, I guess.
-- 
Stefan Richter
-=====-==-=- =-== ==-==
http://arcgraph.de/sr/
