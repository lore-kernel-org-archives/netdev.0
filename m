From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/21] remove dst garbage collector logic
Date: Sat, 17 Jun 2017 22:55:53 -0400 (EDT)
Message-ID: <20170617.225553.1809495134316483088.davem@davemloft.net>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com,
        weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45418 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751727AbdFRCz7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 22:55:59 -0400
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Sat, 17 Jun 2017 10:42:23 -0700

> The current mechanism of dst release is a bit complicated. It is because
> the users of dst get divided into 2 situations:
>   1. Most users take the reference count when using a dst and release the
>      reference count when done.
>   2. Exceptional users like IPv4/IPv6/decnet/xfrm routing code do not take
>      reference count when referencing to a dst due to some histotic reasons.
> 
> Due to those exceptional use cases in 2, reference count being 0 is not an
> adequate evidence to indicate that no user is using this dst. So users in 1
> can't free the dst simply based on reference count being 0 because users in
> 2 might still hold reference to it.
> Instead, a dst garbage list is needed to hold the dst entries that already
> get removed by the users in 2 but are still held by users in 1. And a periodic
> garbage collector task is run to check all the dst entries in the list to see
> if the users in 1 have released the reference to those dst entries.
> If so, the dst is now ready to be freed.
> 
> This logic introduces unnecessary complications in the dst code which makes it
> hard to understand and to debug.
> 
> In order to get rid of the whole dst garbage collector (gc) and make the dst
> code more unified and simplified, we can make the users in 2 also take reference
> count on the dst and release it properly when done.
> This way, dst can be safely freed once the refcount drops to 0 and no gc
> thread is needed anymore.
> 
> This patch series' target is to completely get rid of dst gc logic and free
> dst based on reference count only.
> Patch 1-3 are preparation patches to do some cleanup/improvement on the existing
> code to make later work easier.
> Patch 4-21 are real implementations.
> In these patches, a temporary flag DST_NOGC is used to help transition
> those exceptional users one by one. Once every component is transitioned,
> this temporary flag is removed.
> By the end of this patch series, all dst are refcounted when being used
> and released when done. And dst will be freed when its refcount drops to 0.
> No dst gc task is running anymore.
> 
> Note: This patch series depends on the decnet fix that was sent right before:
>       "decnet: always not take dst->__refcnt when inserting dst into hash table"
> 
> 
> v2:
>   add curly braces in udp_v4/6_early_demux() in patch 02
>   add EXPORT_SYMBOL() for dst_dev_put() in patch 05

Series applied, thanks!
