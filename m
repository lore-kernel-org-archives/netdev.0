From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Wed, 15 Sep 2010 07:35:29 +0200
Message-ID: <20100915053529.GB25566@redhat.com>
References: <201009091319.40274.rusty@rustcorp.com.au>
 <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com>
 <201009092144.26484.rusty@rustcorp.com.au>
 <OF371A1B54.B0F5B4A1-ON65257799.00491939-65257799.004BBB65@in.ibm.com>
 <20100912114637.GB22982@redhat.com>
 <OF32429FD6.3F8CAEC5-ON6525779D.00169473-6525779D.0017A613@in.ibm.com>
 <20100913090415.GB29333@redhat.com>
 <4C8E4A66.8030907@codemonkey.ws>
 <20100913163037.GA18233@redhat.com>
 <4C8E58C3.7060108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751298Ab0IOFle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 01:41:34 -0400
Content-Disposition: inline
In-Reply-To: <4C8E58C3.7060108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 13, 2010 at 07:00:51PM +0200, Avi Kivity wrote:
>  On 09/13/2010 06:30 PM, Michael S. Tsirkin wrote:
> >Trouble is, each vhost-net device is associated with 1 tun/tap
> >device which means that each vhost-net device is associated with a
> >transmit and receive queue.
> >
> >I don't know if you'll always have an equal number of transmit and
> >receive queues but there's certainly  challenge in terms of
> >flexibility with this model.
> >
> >Regards,
> >
> >Anthony Liguori
> >Not really, TX and RX can be mapped to different devices,
> >or you can only map one of these. What is the trouble?
> 
> Suppose you have one multiqueue-capable ethernet card.  How can you
> connect it to multiple rx/tx queues?
> tx is in principle doable, but what about rx?
> 
> What does "only map one of these" mean?  Connect the device with one
> queue (presumably rx), and terminate the others?
> 
> 
> Will packet classification work (does the current multiqueue
> proposal support it)?
> 

This is a non trivial problem, but
this needs to be handled in tap, not in vhost net.
If tap gives you multiple queues, vhost-net will happily
let you connect vqs to these.

> 
> -- 
> error compiling committee.c: too many arguments to function
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
