From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: XDP offload to hypervisor
Date: Tue, 24 Jan 2017 04:47:46 +0200
Message-ID: <20170124044527-mutt-send-email-mst@kernel.org>
References: <20170123230727-mutt-send-email-mst@kernel.org>
 <20170124010201.GB60699@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, jasowang@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33414 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbdAXCrr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 21:47:47 -0500
Content-Disposition: inline
In-Reply-To: <20170124010201.GB60699@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 05:02:02PM -0800, Alexei Starovoitov wrote:
> > Another issue is around host/guest ABI. Guest BPF could add new features
> > at any point. What if hypervisor can not support it all?  I guess we
> > could try loading program into hypervisor and run it within guest on
> > failure to load, but this ignores question of cross-version
> > compatibility - someone might start guest on a new host
> > then try to move to an old one. So we will need an option
> > "behave like an older host" such that guest can start and then
> > move to an older host later. This will likely mean
> > implementing this validation of programs in qemu userspace unless linux
> > can supply something like this. Is this (disabling some features)
> > something that might be of interest to larger bpf community?
> 
> In case of x86->nic offload not all xdp features will be supported
> by the nic and that is expected. The user will request 'offload of xdp prog'
> in some form and if it cannot be done, then xdp programs will run
> on x86 as before. Same thing, I imagine, is applicable to virtio->host
> offload. Therefore I don't see a need for user space visible
> feature negotiation.

Not userspace visible - guest visible. As guests move between hosts,
you need to make sure source host does not commit to a feature that
destination host does not support.

-- 
MST
