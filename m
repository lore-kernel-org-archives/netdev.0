From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 20 Aug 2009 16:55:48 +0930
Message-ID: <200908201655.48779.rusty@rustcorp.com.au>
References: <cover.1249930169.git.mst@redhat.com> <20090813144129.GB5080@redhat.com> <200908131653.47029.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57519 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753707AbZHTHZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 03:25:53 -0400
In-Reply-To: <200908131653.47029.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2009 12:23:46 am Arnd Bergmann wrote:
> On Thursday 13 August 2009, Michael S. Tsirkin wrote:
> > The best way to do this IMO would be to add zero copy support to raw
> > sockets, vhost will then get it basically for free.
> 
> Yes, that would be nice. I wonder if that could lead to security
> problems on TX though. I guess It will only bring significant performance
> improvements if we leave the data writable in the user space or guest
> during the operation. If the user finds the right timing, it could
> modify the frame headers after they have been checked using netfilter,
> or while the frames are being consumed in the kernel (e.g. an NFS
> server running in a guest).

For this reason, we always linearize parts of packets we're filtering.
ie. copy.

Cheers,
Rusty.
