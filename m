From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: Defer skb allocation in receive path
Date: Mon, 4 Jan 2010 23:14:54 +0200
Message-ID: <20100104211454.GB21488@redhat.com>
References: <1261122090.4148.24.camel@localhost.localdomain> <1261122289.4148.27.camel@localhost.localdomain> <20091224133749.GB2855@amit-x200.redhat.com> <1262640344.18773.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amit Shah <amit.shah@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045Ab0ADVSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 16:18:01 -0500
Content-Disposition: inline
In-Reply-To: <1262640344.18773.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 04, 2010 at 01:25:44PM -0800, Shirley Ma wrote:
> Hello Amit,
> 
> Sorry for late response. I am just back from vacation.
> 
> On Thu, 2009-12-24 at 19:07 +0530, Amit Shah wrote:
> > > +static void free_unused_bufs(struct virtnet_info *vi)
> > > +{
> > > +     void *buf;
> > > +     while (vi->num) {
> > > +             buf = vi->rvq->vq_ops->detach_unused_buf(vi->rvq);
> > > +             if (!buf)
> > > +                     continue;
> > 
> > Do you mean 'break' here?
> 
> Nope, it means break since the buffer usage is not sorted by descriptors
> from my understanding. It breaks when vi->num reaches 0.
> 
> Thanks
> Shirley
t

I don't understand.
detach_unused_buf has:
+               if (!vq->data[i])
+                       continue;

so it will never return NULL unless no more buffers?  breaking here ad
BUG_ON(vi->num) as Amit suggests seems cleaner than looping forever if
there's a bug.

-- 
MST
