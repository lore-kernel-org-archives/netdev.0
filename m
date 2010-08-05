From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Using virtio as a physical (wire-level) transport
Date: Fri, 6 Aug 2010 00:30:50 +0300
Message-ID: <20100805213050.GA24984@redhat.com>
References: <20100804230441.GJ23951@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Zang Roy <r61911@freescale.com>, netdev@vger.kernel.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab0HEVgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 17:36:42 -0400
Content-Disposition: inline
In-Reply-To: <20100804230441.GJ23951@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ira,

> Making my life harder since the last time I tried this, mainline commit
> 7c5e9ed0c (virtio_ring: remove a level of indirection) has removed the
> possibility of using an alternative virtqueue implementation. The commit
> message suggests that you might be willing to add this capability back.
> Would this be an option?

Sorry about that.

With respect to this commit, we only had one implementation upstream
and extra levels of indirection made extending the API
much harder for no apparent benefit.

When there's more than one ring implementation with very small amount of
common code, I think that it might make sense to readd the indirection
back, to separate the code cleanly.

OTOH if the two implementations share a lot of code, I think that it
might be better to just add a couple of if statements here and there.
This way compiler even might have a chance to compile the code out if
the feature is disabled in kernel config.

-- 
MST
