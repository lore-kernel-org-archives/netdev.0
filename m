From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Wed, 26 Oct 2016 20:07:19 +0300
Message-ID: <20161026200153-mutt-send-email-mst@kernel.org>
References: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
 <20161026155202.5d99d935@redhat.com>
 <20161026185743-mutt-send-email-mst@kernel.org>
 <20161026.125245.1630138589657247338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brouer@redhat.com, shrijeet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, shm@cumulusnetworks.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755000AbcJZRHV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 13:07:21 -0400
Content-Disposition: inline
In-Reply-To: <20161026.125245.1630138589657247338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 12:52:45PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 26 Oct 2016 19:36:45 +0300
> 
> > On Wed, Oct 26, 2016 at 03:52:02PM +0200, Jesper Dangaard Brouer wrote:
> >> On Sat, 22 Oct 2016 04:07:23 +0000
> >> Shrijeet Mukherjee <shrijeet@gmail.com> wrote:
> >> 
> >> > This patch adds support for xdp ndo and also inserts the xdp program
> >> > call into the merged RX buffers and big buffers paths
> >> 
> >> I really appreciate you are doing this for virtio_net.
> >> 
> >> My first question is: Is the (packet) page data writable?
> >> (MST might be able to answer?)
> >> 
> >> As this is currently an XDP requirement[1].  
> > 
> > I'm not sure I understand what does writable mean.
> > Could you explain a bit more pls?
> > We do copy data into skb ATM but I plan to change that.
> 
> The packet data area must be writable,

This is the part I don't fully understand.
It's in RAM so of course it's writeable.

> and the page it lives in must
> not be shared with any other entity in the system.

We share pages between arbitrary multiple packets. I think that's
OK - or is there an assumption that multiple programs
will be attached with different priveledges?

> This is because the eBPF program that executes via XDP must be able
> to modify and read arbitrary parts of the packet area.

-- 
MST
