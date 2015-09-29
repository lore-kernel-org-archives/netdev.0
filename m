From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
Date: Tue, 29 Sep 2015 09:12:19 +0200
Message-ID: <20150929091219.40d1e217@redhat.com>
References: <20150928122444.15409.10498.stgit@canyon>
	<20150928122629.15409.69466.stgit@canyon>
	<alpine.DEB.2.20.1509281011250.30332@east.gentwo.org>
	<20150928175114.07e85114@redhat.com>
	<alpine.DEB.2.20.1509281129100.30876@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932622AbbI2HMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 03:12:25 -0400
In-Reply-To: <alpine.DEB.2.20.1509281129100.30876@east.gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 28 Sep 2015 11:30:00 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > Not knowing SLUB as well as you, it took me several hours to realize
> > init_object() didn't overwrite the freepointer in the object.  Thus, I
> > think these comments make the reader aware of not-so-obvious
> > side-effects of SLAB_POISON and SLAB_RED_ZONE.
> 
> From the source:
> 
> /*
>  * Object layout:
>  *
>  * object address
>  *      Bytes of the object to be managed.
>  *      If the freepointer may overlay the object then the free
>  *      pointer is the first word of the object.
>  *
>  *      Poisoning uses 0x6b (POISON_FREE) and the last byte is
>  *      0xa5 (POISON_END)
>  *
>  * object + s->object_size
>  *      Padding to reach word boundary. This is also used for Redzoning.
>  *      Padding is extended by another word if Redzoning is enabled and
>  *      object_size == inuse.
>  *
>  *      We fill with 0xbb (RED_INACTIVE) for inactive objects and with
>  *      0xcc (RED_ACTIVE) for objects in use.
>  *
>  * object + s->inuse
>  *      Meta data starts here.
>  *
>  *      A. Free pointer (if we cannot overwrite object on free)
>  *      B. Tracking data for SLAB_STORE_USER
>  *      C. Padding to reach required alignment boundary or at mininum
>  *              one word if debugging is on to be able to detect writes
>  *              before the word boundary.

Okay, I will remove the comment.

The best doc on SLUB and SLAB layout comes from your slides titled:
 "Slab allocators in the Linux Kernel: SLAB, SLOB, SLUB"

Lets gracefully add a link to the slides here:
 http://events.linuxfoundation.org/sites/events/files/slides/slaballocators.pdf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
