From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Date: Tue, 16 Jun 2015 11:04:45 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1506161104060.5683@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155256.18824.42651.stgit@devil> <20150616072806.GC13125@js1304-P5Q-DELUXE> <20150616102110.55208fdd@redhat.com> <20150616105732.2bc37714@redhat.com> <CAAmzW4OM-afGBZbWZzcH7O-mivNWvyeKpMVV4Os+i4Xb7GPgmg@mail.gmail.com>
 <alpine.DEB.2.11.1506161008350.3496@east.gentwo.org> <20150616175231.427499ae@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joonsoo Kim <js1304@gmail.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-03v.sys.comcast.net ([69.252.207.35]:41578 "EHLO
	resqmta-ch2-03v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751404AbbFPQEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 12:04:46 -0400
In-Reply-To: <20150616175231.427499ae@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Jun 2015, Jesper Dangaard Brouer wrote:

> It is very important that everybody realizes that the save+restore
> variant is very expensive, this is key:
>
> CPU: i7-4790K CPU @ 4.00GHz
>  * local_irq_{disable,enable}:  7 cycles(tsc) - 1.821 ns
>  * local_irq_{save,restore}  : 37 cycles(tsc) - 9.443 ns
>
> Even if EVERY object need to call slowpath/__slab_free() it will be
> faster than calling the fallback.  Because I've demonstrated the call
> this_cpu_cmpxchg_double() costs 9 cycles.

But the cmpxchg also stores a value. You need to add the cost of the store
to the cycles.
