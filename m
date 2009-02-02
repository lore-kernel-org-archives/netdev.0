From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH v3 2/4] virtio_net: Add a set_rx_mode interface
Date: Mon, 02 Feb 2009 14:34:07 -0700
Message-ID: <1233610447.7026.970.camel@lappy>
References: <20090201200504.8183.58421.stgit@debian.lart>
	 <20090201200515.8183.81496.stgit@debian.lart>
	 <200902022022.20781.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:39935 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbZBBVeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:34:01 -0500
In-Reply-To: <200902022022.20781.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

On Mon, 2009-02-02 at 20:22 +1030, Rusty Russell wrote:
> On Monday 02 February 2009 06:35:15 Alex Williamson wrote:
> > +	sg_set_buf(&sg, &promisc, sizeof(promisc));
> > +
> > +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
> > +				  VIRTIO_NET_CTRL_RX_PROMISC,
> > +				  &sg, 1, 0))
> 
> Hmm, can we use sg_init_one(&sg, &promisc, sizeof(promisc)) then pass two sg
> to virtnet_send_command?  ie.  change virtnet_send_command to:
> 
> 	static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
>                                 struct scatterlist *out, struct scatterlist *in);
> 
> NULL = no sg, otherwise it's assumed to be a nicely terminated sg?  Neater for
> the callers I think...

I think the caller still ends up passing the counts of out and in
entries here or else we have to walk the lists in send_command().
Doable, but doesn't seem to be common practice that I can find.  We
should also then clear the termination once we copy the sg[] into our
own, but functions to do that don't seem to exist (need an
sg_unmark_end()).  I had avoided anything that would call
sg_init_table() on the caller provided sg[] to avoid that problem, does
it need to be addressed?

> > -#define VIRTIO_NET_MAX_CTRL_ARGS   2
> > +#define VIRTIO_NET_MAX_CTRL_ARGS   3
> 
> Oh, and this should probably be called VIRTNET_SEND_COMMAND_SG_MAX, and be
> this value minus 2 (ie. informative for the caller of virtnet_send_command).

Yes, and yes to moving it to the c file, no need to expose it.  Thanks,

Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

