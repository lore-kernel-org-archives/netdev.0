From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Thu, 3 Feb 2011 18:20:42 +0200
Message-ID: <20110203162042.GA10028@redhat.com>
References: <20110202173213.GA13907@redhat.com>
 <1296670311.25430.49.camel@localhost.localdomain>
 <20110202182720.GB14257@redhat.com>
 <1296674975.25430.59.camel@localhost.localdomain>
 <20110202201731.GB15150@redhat.com>
 <1296680585.25430.98.camel@localhost.localdomain>
 <20110202212047.GD15150@redhat.com>
 <1296709556.25430.140.camel@localhost.localdomain>
 <20110203061326.GC22230@redhat.com>
 <1296748680.25430.169.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448Ab1BCQVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 11:21:06 -0500
Content-Disposition: inline
In-Reply-To: <1296748680.25430.169.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 03, 2011 at 07:58:00AM -0800, Shirley Ma wrote:
> On Thu, 2011-02-03 at 08:13 +0200, Michael S. Tsirkin wrote:
> > > Initial TCP_STREAM performance results I got for guest to local
> > host 
> > > 4.2Gb/s for 1K message size, (vs. 2.5Gb/s)
> > > 6.2Gb/s for 2K message size, and (vs. 3.8Gb/s)
> > > 9.8Gb/s for 4K message size. (vs.5.xGb/s)
> > 
> > What is the average packet size, # bytes per ack, and the # of
> > interrupts
> > per packet? It could be that just slowing down trahsmission
> > makes GSO work better. 
> 
> There is no TX interrupts with dropping packet.
> 
> GSO/TSO is the key for small message performance, w/o GSO/TSO, the
> performance is limited to about 2Gb/s no matter how big the message size
> it is. I think any work we try here will increase large packet size
> rate. BTW for dropping packet, TCP increased fast retrans, not slow
> start. 
> 
> I will collect tcpdump, netstart before and after data to compare packet
> size/rate w/o w/i the patch.
> 
> Thanks
> Shirley

Just a thought: does it help to make tx queue len of the
virtio device smaller?
E.g. match the vq size?

-- 
MST
