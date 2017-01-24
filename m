From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: XDP offload to hypervisor
Date: Mon, 23 Jan 2017 19:50:31 -0800
Message-ID: <20170124035029.GA89215@ast-mbp.thefacebook.com>
References: <20170123230727-mutt-send-email-mst@kernel.org>
 <20170124010201.GB60699@ast-mbp.thefacebook.com>
 <20170124053207-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, jasowang@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35039 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXDug (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 22:50:36 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so11220389pfa.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 19:50:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170124053207-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 05:33:37AM +0200, Michael S. Tsirkin wrote:
> On Mon, Jan 23, 2017 at 05:02:02PM -0800, Alexei Starovoitov wrote:
> > Frankly I don't understand the whole virtio nit picking that was happening.
> > imo virtio+xdp by itself is only useful for debugging, development and testing
> > of xdp programs in a VM. The discussion about performance of virtio+xdp
> > will only be meaningful when corresponding host part is done.
> > Likely in the form of vhost extensions and may be driver changes.
> > Trying to optimize virtio+xdp when host is doing traditional skb+vhost
> > isn't going to be impactful.
> 
> Well if packets can be dropped without a host/guest
> transition then yes, that will have an impact even
> with traditional skbs.

I don't think it's worth optimizing for though, since the speed of drop
matters for ddos-like use case and if we let host be flooded with skbs,
we already lost, since the only thing cpu is doing is allocating skbs
and moving them around. Whether drop is happening upon entry into VM
or host does it in some post-vhost layer doesn't change the picture much.
That said, I do like the idea of offloading virto+xdp into host somehow.
