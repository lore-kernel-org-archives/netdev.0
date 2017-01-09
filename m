From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Tue, 10 Jan 2017 01:05:57 +0200
Message-ID: <20170110010531-mutt-send-email-mst@kernel.org>
References: <20170102223031.11541.28717.stgit@john-Precision-Tower-5810>
 <402027b4-58c7-aa1b-5079-74e31448f544@redhat.com>
 <586BD5D5.6020100@gmail.com>
 <1caf1ffc-0f46-067e-0f0d-a93b408b4ffd@redhat.com>
 <586D458F.5050705@gmail.com>
 <068f0116-b37e-eb44-8c60-1781a9d5255e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750821AbdAIXF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 18:05:59 -0500
Content-Disposition: inline
In-Reply-To: <068f0116-b37e-eb44-8c60-1781a9d5255e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 05, 2017 at 11:09:14AM +0800, Jason Wang wrote:
> 
> 
> On 2017年01月05日 02:57, John Fastabend wrote:
> > [...]
> > 
> > > On 2017年01月04日 00:48, John Fastabend wrote:
> > > > On 17-01-02 10:14 PM, Jason Wang wrote:
> > > > > On 2017年01月03日 06:30, John Fastabend wrote:
> > > > > > XDP programs can not consume multiple pages so we cap the MTU to
> > > > > > avoid this case. Virtio-net however only checks the MTU at XDP
> > > > > > program load and does not block MTU changes after the program
> > > > > > has loaded.
> > > > > > 
> > > > > > This patch sets/clears the max_mtu value at XDP load/unload time.
> > > > > > 
> > > > > > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > > > > > ---
> > [...]
> > 
> > > > OK so this logic is a bit too simply. When it resets the max_mtu I guess it
> > > > needs to read the mtu via
> > > > 
> > > >      virtio_cread16(vdev, ...)
> > > > 
> > > > or we may break the negotiated mtu.
> > > Yes, this is a problem (even use ETH_MAX_MTU). We may need a method to notify
> > > the device about the mtu in this case which is not supported by virtio now.
> > Note this is not really a XDP specific problem. The guest can change the MTU
> > after init time even without XDP which I assume should ideally result in a
> > notification if the MTU is negotiated.
> 
> Yes, Michael, do you think we need add some mechanism to notify host about
> MTU change in this case?
> 
> Thanks

Why does host care?
