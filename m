From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Fri, 8 Sep 2017 02:56:20 +0200
Message-ID: <20170908025620.47d0ad2e@elisabeth>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, lorenzo@google.com
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751981AbdIHA41 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 20:56:27 -0400
In-Reply-To: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Sep 2017 18:52:02 -0600
Subash Abhinov Kasiviswanathan <subashab@codeaurora.org> wrote:

> We are seeing a possible use after free in ip6_dst_destroy.
> 
> It appears as if memory of the __DST_METRICS_PTR(old) was freed in some 
> path and allocated
> to ion driver. ion driver has also freed it. Finally the memory is freed 
> by the
> fib gc and crashes since it is already deallocated.
> 
> Target is running an ARM64 Android based 4.9 kernel.
> Issue was seen once on a regression rack (sorry, no reproducer).
> Any pointers to debug this is highly appreciated.
> 
> [ 3489.470581] [<ffffff83c0a289c0>] object_err+0x4c/0x5c
> [ 3489.470586] [<ffffff83c0a2b284>] free_debug_processing+0x2e0/0x398
> [ 3489.470589] [<ffffff83c0a2b63c>] __slab_free+0x300/0x3e0
> [ 3489.470593] [<ffffff83c0a2bfc8>] kfree+0x28c/0x290
> [ 3489.470601] [<ffffff83c16b9580>] 
> __dst_destroy_metrics_generic+0x6c/0x78
> [ 3489.470609] [<ffffff83c17d3408>] ip6_dst_destroy+0xb0/0xb4

Should be fixed by:

commit ad65a2f05695aced349e308193c6e2a6b1d87112
Author: Wei Wang <weiwan@google.com>
Date:   Sat Jun 17 10:42:35 2017 -0700

    ipv6: call dst_hold_safe() properly
