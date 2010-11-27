From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [Q] How to invalidate ARP cache for a network device from
 within kernel
Date: Sat, 27 Nov 2010 17:44:04 +0200
Message-ID: <1290872644.15076.1.camel@maxim-laptop>
References: <1290793099.3716.21.camel@maxim-laptop>
	 <20101127021833.328e8942@stein> <1290821143.4145.3.camel@maxim-laptop>
	 <20101127093342.3f1d01ce@stein>  <20101127161907.791a3b7c@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux1394-devel <linux1394-devel@lists.sourceforge.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37907 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab0K0PoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 10:44:09 -0500
Received: by bwz15 with SMTP id 15so2643674bwz.19
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 07:44:08 -0800 (PST)
In-Reply-To: <20101127161907.791a3b7c@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-11-27 at 16:19 +0100, Stefan Richter wrote:
> On Nov 27 Stefan Richter wrote:
> > > @@ -1593,10 +1593,15 @@ static void fwnet_update(struct fw_unit
> > > *unit) {
> > >  	struct fw_device *device = fw_parent_device(unit);
> > >  	struct fwnet_peer *peer = dev_get_drvdata(&unit->device);
> > > +	struct fwnet_device *dev = peer->dev;
> > >  	int generation;
> > >  
> > >  	generation = device->generation;
> > >  
> > > +	fw_iso_context_stop(dev->broadcast_rcv_context);
> > > +	fw_iso_context_start(dev->broadcast_rcv_context, -1, 0,
> > > +			FW_ISO_CONTEXT_MATCH_ALL_TAGS);
> [...]
> > OTOH, is this actually necessary on normal bus resets?  It should only
> > be necessary after PM resume, right?  If so, perhaps do it only if the
> > generation increased by more than one.
> 
> Actually, shouldn't context restart at resume happen in firewire-ohci
> rather?  Any other protocol driver which uses isochronous I/O (be it a
> kernel driver or userspace driver) would have the same issue, I guess.
Well, the spec says that upon bus reset ISO channels must be allocated
again.
This somewhat mimics that, although it can be done better.

Of course the same true after suspend/resume.

Best regards,
	Maxim Levitsky

