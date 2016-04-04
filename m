From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Mon, 4 Apr 2016 15:07:00 +0200
Message-ID: <20160404150700.1456ae80@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
	<57022A85.6040002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	john.fastabend@gmail.com, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbcDDNHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 09:07:06 -0400
In-Reply-To: <57022A85.6040002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 04 Apr 2016 10:49:09 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 04/02/2016 03:21 AM, Brenden Blanco wrote:
> > Add a new bpf prog type that is intended to run in early stages of the
> > packet rx path. Only minimal packet metadata will be available, hence a new
> > context type, struct xdp_metadata, is exposed to userspace. So far only
> > expose the readable packet length, and only in read mode.
> >
> > The PHYS_DEV name is chosen to represent that the program is meant only
> > for physical adapters, rather than all netdevs.
> >
> > While the user visible struct is new, the underlying context must be
> > implemented as a minimal skb in order for the packet load_* instructions
> > to work. The skb filled in by the driver must have skb->len, skb->head,
> > and skb->data set, and skb->data_len == 0.
> >
[...]
> 
> Do you plan to support bpf_skb_load_bytes() as well? I like using
> this API especially when dealing with larger chunks (>4 bytes) to
> load into stack memory, plus content is kept in network byte order.
> 
> What about other helpers such as bpf_skb_store_bytes() et al that
> work on skbs. Do you intent to reuse them as is and thus populate
> the per cpu skb with needed fields (faking linear data), or do you
> see larger obstacles that prevent for this?

Argh... maybe the minimal pseudo/fake SKB is the wrong "signal" to send
to users of this API.

The hole idea is that an SKB is NOT allocated yet, and not needed at
this level.  If we start supporting calling underlying SKB functions,
then we will end-up in the same place (performance wise).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
