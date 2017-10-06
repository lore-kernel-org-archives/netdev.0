From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V4 PATCH 2/5] bpf: XDP_REDIRECT enable use of cpumap
Date: Fri, 6 Oct 2017 14:01:23 +0200
Message-ID: <20171006140123.5f94f1e7@redhat.com>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
        <150711863012.9499.383645968070658124.stgit@firesoul>
        <59D60505.2040004@iogearbox.net>
        <20171006131748.75185f65@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54280 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751925AbdJFMC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 08:02:29 -0400
In-Reply-To: <20171006131748.75185f65@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Oct 2017 13:17:48 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > > -int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
> > > +int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp,
> > > +		    struct net_device *dev_rx)
> > >   {
> > >   	struct xdp_pkt *xdp_pkt;
> > >   	int headroom;
> > > @@ -505,7 +506,7 @@ int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu, struct xdp_buff *xdp)
> > >   	xdp_pkt = xdp->data_hard_start;
> > >   	xdp_pkt->data = xdp->data;
> > >   	xdp_pkt->len  = xdp->data_end - xdp->data;
> > > -	xdp_pkt->headroom = headroom;
> > > +	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);    
> > 
> > (Just a note, bit confusing that first two patches add and extend
> >   this, and only in the third you add the xdp->data_meta handling,
> >   makes it harder to review at least.)  
> 
> Sorry.  This is a left-overs from rebasing and measuring the cost of
> transferring only the pointer to the page, and remote put_page().
> And your xdp->data_meta, happen basically while my patches was in-flight.
> 
> I'll move this one-line back to patch 2, to spreading over too many
> patches.

I instead choose to move the creation of cpu_map_enqueue() into this
patch, but in a more simple version stating explicit that this is only
seen as a void pointer enqueue.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
