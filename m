From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Wed, 15 Sep 2010 07:40:43 +0200
Message-ID: <20100915054043.GC25566@redhat.com>
References: <201009091319.40274.rusty@rustcorp.com.au>
 <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com>
 <201009092144.26484.rusty@rustcorp.com.au>
 <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com>
 <20100912114637.GB22982@redhat.com>
 <OF32429FD6.3F8CAEC5-ON6525779D.00169473-6525779D.0017A613@in.ibm.com>
 <20100913090415.GB29333@redhat.com>
 <4C8E4A66.8030907@codemonkey.ws>
 <20100913163037.GA18233@redhat.com>
 <4C8E61FB.30805@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907Ab0IOFqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 01:46:49 -0400
Content-Disposition: inline
In-Reply-To: <4C8E61FB.30805@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 13, 2010 at 12:40:11PM -0500, Anthony Liguori wrote:
> On 09/13/2010 11:30 AM, Michael S. Tsirkin wrote:
> >On Mon, Sep 13, 2010 at 10:59:34AM -0500, Anthony Liguori wrote:
> >>On 09/13/2010 04:04 AM, Michael S. Tsirkin wrote:
> >>>On Mon, Sep 13, 2010 at 09:50:42AM +0530, Krishna Kumar2 wrote:
> >>>>"Michael S. Tsirkin"<mst@redhat.com>   wrote on 09/12/2010 05:16:37 PM:
> >>>>
> >>>>>"Michael S. Tsirkin"<mst@redhat.com>
> >>>>>09/12/2010 05:16 PM
> >>>>>
> >>>>>On Thu, Sep 09, 2010 at 07:19:33PM +0530, Krishna Kumar2 wrote:
> >>>>>>Unfortunately I need a
> >>>>>>constant in vhost for now.
> >>>>>Maybe not even that: you create multiple vhost-net
> >>>>>devices so vhost-net in kernel does not care about these
> >>>>>either, right? So this can be just part of vhost_net.h
> >>>>>in qemu.
> >>>>Sorry, I didn't understand what you meant.
> >>>>
> >>>>I can remove all socks[] arrays/constants by pre-allocating
> >>>>sockets in vhost_setup_vqs. Then I can remove all "socks"
> >>>>parameters in vhost_net_stop, vhost_net_release and
> >>>>vhost_net_reset_owner.
> >>>>
> >>>>Does this make sense?
> >>>>
> >>>>Thanks,
> >>>>
> >>>>- KK
> >>>Here's what I mean: each vhost device includes 1 TX
> >>>and 1 RX VQ. Instead of teaching vhost about multiqueue,
> >>>we could simply open /dev/vhost-net multiple times.
> >>>How many times would be up to qemu.
> >>Trouble is, each vhost-net device is associated with 1 tun/tap
> >>device which means that each vhost-net device is associated with a
> >>transmit and receive queue.
> >>
> >>I don't know if you'll always have an equal number of transmit and
> >>receive queues but there's certainly  challenge in terms of
> >>flexibility with this model.
> >>
> >>Regards,
> >>
> >>Anthony Liguori
> >Not really, TX and RX can be mapped to different devices,
> 
> It's just a little odd.  Would you bond multiple tun tap devices to
> achieve multi-queue TX?  For RX, do you somehow limit RX to only one
> of those devices?

Exatly in the way the patches we discuss here do this:
we already have a per-queue fd.

> If we were doing this in QEMU (and btw, there needs to be userspace
> patches before we implement this in the kernel side),

I agree that Feature parity is nice to have, but
I don't see a huge problem with (hopefully temporarily) only
supporting feature X with kernel acceleration, BTW.
This is already the case with checksum offloading features.

> I think it
> would make more sense to just rely on doing a multithreaded write to
> a single tun/tap device and then to hope that in can be made smarter
> at the macvtap layer.

No, an fd serializes access, so you need seperate fds for multithreaded
writes to work.  Think about how e.g. select will work.

> Regards,
> 
> Anthony Liguori
> 
> Regards,
> 
> Anthony Liguori
> 
> >or you can only map one of these. What is the trouble?
> >What other features would you desire in terms of flexibility?
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
