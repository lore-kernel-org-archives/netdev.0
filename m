From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v2 PATCH] net: Update alloc frag to reduce get/put page usage
 and recycle pages
Date: Fri, 13 Jul 2012 11:06:34 +0200
Message-ID: <1342170394.3265.8339.camel@edumazet-glaptop>
References: <20120713001922.27393.1358.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	alexander.duyck@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37688 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab2GMJGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 05:06:38 -0400
Received: by bkwj10 with SMTP id j10so2927524bkw.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 02:06:37 -0700 (PDT)
In-Reply-To: <20120713001922.27393.1358.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 17:23 -0700, Alexander Duyck wrote:
> This patch is meant to help improve performance by reducing the number of
> locked operations required to allocate a frag on x86 and other platforms.
> This is accomplished by using atomic_set operations on the page count
> instead of calling get_page and put_page.  It is based on work originally
> provided by Eric Dumazet.
> 
> In addition it also helps to reduce memory overhead when using TCP.  This
> is done by recycling the page if the only holder of the frame is the
> netdev_alloc_frag call itself.  This can occur when skb heads are stolen by
> either GRO or TCP and the driver providing the packets is using paged frags
> to store all of the data for the packets.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
> v2: Reverted back to something closer to the patch that Eric originally
>     submitted.  The main goal in all this is to get the removal of expensive
>     atomic ops and recycling added for now while Eric is still working on
>     an approach that uses larger pages.
> 
>  net/core/skbuff.c |   28 ++++++++++++++++++++--------
>  1 files changed, 20 insertions(+), 8 deletions(-)

Signed-off-by: Eric Dumazet <edumazet@google.com>
