From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Wed, 7 Oct 2015 12:39:19 +0200
Message-ID: <20151007123919.27a9c823@redhat.com>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<20151002154039.69f82bdc@redhat.com>
	<20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
	<20151005212639.35932b6c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
	brouer@redhat.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750916AbbJGKjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 06:39:23 -0400
In-Reply-To: <20151005212639.35932b6c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 5 Oct 2015 21:26:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Fri, 2 Oct 2015 14:50:44 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
[...] 
>  
> > Deleting the BUG altogether sounds the best solution.  As long as the
> > kernel crashes in some manner, we'll be able to work out what happened.
> > And it's cant-happen anyway, isn't it?
> 
> To me WARN_ON() seems like a good "documentation" if it does not hurt
> performance.  I don't think removing the WARN_ON() will improve
> performance, but I'm willing to actually test if it matters.

I tested removing BUG/WARN_ON altogether, and it gives slightly worse
performance. The icache-misses only increase approx 14% (not 112% as
before).  This, I'm willing to attribute to some code alignment issue.

Thus, let us just keep the WARN_ON() and move along.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
