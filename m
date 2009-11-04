From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Date: Wed, 4 Nov 2009 14:15:33 +0100
Message-ID: <20091104131533.GM31511@one.firstfloor.org>
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <878wema6o0.fsf@basil.nowhere.org> <20091104121009.GF8398@redhat.com> <20091104125957.GL31511@one.firstfloor.org> <20091104130828.GC8920@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org,
	akpm@linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60944 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbZKDNP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:15:28 -0500
Content-Disposition: inline
In-Reply-To: <20091104130828.GC8920@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 04, 2009 at 03:08:28PM +0200, Michael S. Tsirkin wrote:
> On Wed, Nov 04, 2009 at 01:59:57PM +0100, Andi Kleen wrote:
> > > Fine?
> > 
> > I cannot say -- are there paths that could drop the device beforehand?
> 
> Do you mean drop the mm reference?

No the reference to the device, which owns the mm for you.

> 
> > (as in do you hold a reference to it?)
> 
> By design I think I always have a reference to mm before I use it.
> 
> This works like this:
> ioctl SET_OWNER - calls get_task_mm, I think this gets a reference to mm
> ioctl SET_BACKEND - checks that SET_OWNER was run, starts virtqueue
> ioctl RESET_OWNER - stops virtqueues, drops the reference to mm
> file close - stops virtqueues, if we still have it then drops mm
> 
> This is why I think I can call use_mm/unuse_mm while virtqueue is running,
> safely.
> Makes sense?

Do you protect against another thread doing RESET_OWNER in parallel while
RESET_OWNER runs?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
