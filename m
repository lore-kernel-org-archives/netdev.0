From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v3 2/4] virtio_net: Add a set_rx_mode interface
Date: Tue, 3 Feb 2009 13:24:00 +1030
Message-ID: <200902031324.00542.rusty@rustcorp.com.au>
References: <20090201200504.8183.58421.stgit@debian.lart> <200902022022.20781.rusty@rustcorp.com.au> <1233610447.7026.970.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41750 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044AbZBCCyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 21:54:06 -0500
In-Reply-To: <1233610447.7026.970.camel@lappy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 February 2009 08:04:07 Alex Williamson wrote:
> Hi Rusty,
> 
> On Mon, 2009-02-02 at 20:22 +1030, Rusty Russell wrote:
> > 	static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> >                                 struct scatterlist *out, struct scatterlist *in);
... 
> I think the caller still ends up passing the counts of out and in
> entries here or else we have to walk the lists in send_command().
> Doable, but doesn't seem to be common practice that I can find.

Yes, I've frequently expressed unhappiness with the API.  I lost that debate
and it doesn't seem fruitful to return to it.

It's not speed-critical, so just iterate.  I refuse to make *my* APIs suck.

> We
> should also then clear the termination once we copy the sg[] into our
> own, but functions to do that don't seem to exist (need an
> sg_unmark_end()).

Ideally we would chain them, but the caller would have to allocate an extra
sg element.

Implement sg_unmark_end() in a separate patch; be sure to CC Jens.

> I had avoided anything that would call
> sg_init_table() on the caller provided sg[] to avoid that problem, does
> it need to be addressed?

I don't think so: those args should in fact be const struct scatterlist *.

Thanks,
Rusty.
