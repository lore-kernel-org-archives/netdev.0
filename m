From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET_DMA: remove unused dma_memcpy_to_kernel_iovec
Date: Mon, 30 Jul 2007 13:47:03 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903539FE1@orsmsx414.amr.corp.intel.com>
References: <bab433300707300739s283bf15fp9d00235cf39fa08b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Nelson, Shannon" <shannon.nelson@intel.com>,
	<netdev@vger.kernel.org>, <viro@ftp.linux.org.uk>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<andy.grover@gmail.com>
To: "pravin" <pravin.shelar@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:50612 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937354AbXG3UrG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 16:47:06 -0400
Content-class: urn:content-classes:message
In-Reply-To: <bab433300707300739s283bf15fp9d00235cf39fa08b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On 7/26/07, David Miller <davem@davemloft.net> wrote:
> > From: Shannon Nelson <shannon.nelson@intel.com>
> > Date: Tue, 24 Jul 2007 17:36:06 -0700
> >
> > > (repost - original eaten by vger?)
> > >
> > > Al Viro pointed out that dma_memcpy_to_kernel_iovec() really was 
> > > unreachable and thus unused.  The code originally was there to 
> > > support in-kernel dma needs, but since it remains unused, 
> we'll pull it out.
> > >
> > > Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> >
> > Applied, thanks Shannon.
> 
> NET_DMA on kernel buffer is pretty useful in ndb, iSCSI 
> target and initiators which uses kernel buffer to receive 
> data. Are there any other issues with dma-memcpy on kernel 
> buffers, if not then following patch makes 
> dma_memcpy_to_kernel_iovec() reachable from tcp_recvmsg.
> I tested this patch and it work fine with unh iSCSI target.
> 
> 
> comments?
> 
> --pravin.

Pravin,
	Currently, NET_DMA only has one provider in the kernel, namely
TCP.  As the driver stands now, I'd like to keep this function out since
it really wasn't being used before.  Shannon has posted patches that
will hopefully make it into 2.6.24 that allow multiple clients to
request DMA channels, so things like iSCSI, ndb, UDP, and NFS can ask
for channels without depending on TCP.  Once we get to that point, if we
see the need for the function, we can add it back.
	We have tried getting iSCSI accelerated through NET_DMA already,
and didn't see the performance boost that made it worthwhile to do.
Once the multiple client channel patches are in, we can revisit that,
since it can be done "right."

Cheers,
-PJ Waskiewicz
