From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers
	function for virtio
Date: Tue, 15 Dec 2009 12:57:48 +0200
Message-ID: <20091215105748.GB11525@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <200911231123.18898.rusty@rustcorp.com.au> <20091208122134.GA17286@redhat.com> <1260534506.30371.6.camel@localhost.localdomain> <1260534805.30371.10.camel@localhost.localdomain> <20091213102632.GB6789@redhat.com> <1260821285.8716.7.camel@localhost.localdomain> <20091214202253.GG6150@redhat.com> <1260832942.4387.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757988AbZLOLAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 06:00:35 -0500
Content-Disposition: inline
In-Reply-To: <1260832942.4387.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2009 at 03:22:22PM -0800, Shirley Ma wrote:
> Hello Michael,
> 
> On Mon, 2009-12-14 at 22:22 +0200, Michael S. Tsirkin wrote:
> > I dont insist, but my idea was
> > 
> > for (;;) {
> >         b = vq->destroy(vq);
> >         if (!b)
> >                 break;
> >         --vi->num;
> >         put_page(b);
> > }
> > 
> > so we do not have to lose track of the counter.
> 
> That's not a bad idea, but to do this, then this fuction will be
> specific for virtio_net device (vi is virtnet_info) only in a generic
> virtqueue API.
> 
> Thanks
> Shirley

No, this code would be in virtio net.
destroy would simply be the virtqueue API that returns
data pointer.

-- 
MST
