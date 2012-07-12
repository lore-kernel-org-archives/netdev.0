From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: Update alloc frag to reduce get/put page
 usage and recycle pages
Date: Thu, 12 Jul 2012 02:29:27 +0200
Message-ID: <1342052967.3265.8210.camel@edumazet-glaptop>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
	 <20120712001810.26542.61967.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, alexander.duyck@gmail.com,
	Eric Dumazet <edumazet@google.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:38054 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895Ab2GLA3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 20:29:31 -0400
Received: by wgbdr13 with SMTP id dr13so1541842wgb.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 17:29:30 -0700 (PDT)
In-Reply-To: <20120712001810.26542.61967.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 17:18 -0700, Alexander Duyck wrote:
> This patch does several things.
> 
> First it reorders the netdev_alloc_frag code so that only one conditional
> check is needed in most cases instead of 2.
> 
> Second it incorporates the atomic_set and atomic_sub_return logic from an
> earlier proposed patch by Eric Dumazet allowing for a reduction in the
> get_page/put_page overhead when dealing with frags.
> 
> Finally it also incorporates the page reuse code so that if the page count
> is dropped to 0 we can just reinitialize the page and reuse it.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---


Hmm, I was working on a version using order-3 pages if available.

(or more exactly 32768 bytes chunks)

I am not sure how your version can help with typical 1500 allocations
(2 skbs per page)
