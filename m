From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/3] virtio: indirect ring entries
 (VIRTIO_RING_F_INDIRECT_DESC)
Date: Tue, 21 Apr 2009 13:59:05 +0100
Message-ID: <1240318745.443.42.camel@blaa>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com>
	 <1229620222-22216-2-git-send-email-markmc@redhat.com>
	 <1229620222-22216-3-git-send-email-markmc@redhat.com>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	Avi Kivity <avi@redhat.com>, Dor Laor <dor@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50956 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbZDUNA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 09:00:26 -0400
In-Reply-To: <1229620222-22216-3-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

On Thu, 2008-12-18 at 17:10 +0000, Mark McLoughlin wrote:
> Add a new feature flag for indirect ring entries. These are ring
> entries which point to a table of buffer descriptors.
> 
> The idea here is to increase the ring capacity by allowing a larger
> effective ring size whereby the ring size dictates the number of
> requests that may be outstanding, rather than the size of those
> requests.
> 
> This should be most effective in the case of block I/O where we can
> potentially benefit by concurrently dispatching a large number of
> large requests. Even in the simple case of single segment block
> requests, this results in a threefold increase in ring capacity.

Apparently, this would also be useful for the windows virtio-net
drivers.

Dor can explain further, but apparently Windows has been observed
passing the driver a packet with >256 fragments when using TSO.

With a ring size of 256, the guest can either drop the packet or copy it
into a single buffer. We'd much rather if we could use an indirect ring
entry to pass this number of fragments without copying.

For reference the original patch was here:

  http://lkml.org/lkml/2008/12/18/212

Cheers,
Mark.

