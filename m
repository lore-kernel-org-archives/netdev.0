From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] decnet: always not take dst->__refcnt when
 inserting dst into hash table
Date: Fri, 16 Jun 2017 15:00:27 -0400 (EDT)
Message-ID: <20170616.150027.1514023118759756329.davem@davemloft.net>
References: <20170616174637.139429-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, kafai@fb.com,
        weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752068AbdFPTAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 15:00:32 -0400
In-Reply-To: <20170616174637.139429-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Fri, 16 Jun 2017 10:46:37 -0700

> From: Wei Wang <weiwan@google.com>
> 
> In the existing dn_route.c code, dn_route_output_slow() takes
> dst->__refcnt before calling dn_insert_route() while dn_route_input_slow()
> does not take dst->__refcnt before calling dn_insert_route().
> This makes the whole routing code very buggy.
> In dn_dst_check_expire(), dnrt_free() is called when rt expires. This
> makes the routes inserted by dn_route_output_slow() not able to be
> freed as the refcnt is not released.
> In dn_dst_gc(), dnrt_drop() is called to release rt which could
> potentially cause the dst->__refcnt to be dropped to -1.
> In dn_run_flush(), dst_free() is called to release all the dst. Again,
> it makes the dst inserted by dn_route_output_slow() not able to be
> released and also, it does not wait on the rcu and could potentially
> cause crash in the path where other users still refer to this dst.
> 
> This patch makes sure both input and output path do not take
> dst->__refcnt before calling dn_insert_route() and also makes sure
> dnrt_free()/dst_free() is called when removing dst from the hash table.
> The only difference between those 2 calls is that dnrt_free() waits on
> the rcu while dst_free() does not.
> 
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Martin KaFai Lau <kafai@fb.com>

Applied and queued up for -stable, thanks.

I've also applied it to net-next for the sake of your dst gc removal
series.

Thanks again.
