From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC 01/12] net: bpf: rename ndo_xdp to ndo_bpf
Date: Wed, 1 Nov 2017 09:00:30 -0700
Message-ID: <20171101090030.4173a900@cakuba.netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
        <20171101015217.10666-2-jakub.kicinski@netronome.com>
        <20171101084142.5a5a9afc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        bblanco@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:47676 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752363AbdKAQAf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 12:00:35 -0400
Received: by mail-qk0-f196.google.com with SMTP id m189so3255257qke.4
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 09:00:34 -0700 (PDT)
In-Reply-To: <20171101084142.5a5a9afc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Nov 2017 08:41:42 +0100, Jesper Dangaard Brouer wrote:
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index fc059f193e7d..edf984406ba0 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -2115,7 +2115,7 @@ static const struct net_device_ops virtnet_netdev = {
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >  	.ndo_poll_controller = virtnet_netpoll,
> >  #endif
> > -	.ndo_xdp		= virtnet_xdp,
> > +	.ndo_bpf		= virtnet_xdp,
> >  	.ndo_xdp_xmit		= virtnet_xdp_xmit,
> >  	.ndo_xdp_flush		= virtnet_xdp_flush,
> >  	.ndo_features_check	= passthru_features_check,  
> 
> Sorry, but I don't understand why this rename is needed.
> 
> Are you going to add another type than BPF_PROG_TYPE_XDP?

I'm adding commands which can be used for cls_bpf programs as well:

+	/* BPF program for offload callbacks, invoked at program load time. */
+	BPF_OFFLOAD_VERIFIER_PREP,
+	BPF_OFFLOAD_TRANSLATE,
+	BPF_OFFLOAD_DESTROY,
