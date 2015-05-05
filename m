From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
Date: Mon, 04 May 2015 17:16:43 -0700
Message-ID: <1430785003.27254.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>
	 <20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33653 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbbEEAQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 20:16:45 -0400
Received: by igbpi8 with SMTP id pi8so76573165igb.0
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 17:16:45 -0700 (PDT)
In-Reply-To: <20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-04 at 16:14 -0700, Alexander Duyck wrote:
> This change adds a function called skb_free_frag which is meant to
> compliment the function __alloc_page_frag.  The general idea is to enable a
> more lightweight version of page freeing since we don't actually need all
> the overhead of a put_page, and we don't quite fit the model of __free_pages.

Could you describe what are the things that put_page() handle that we
don't need for skb frags ?

It looks the change could benefit to other users (outside of networking)
