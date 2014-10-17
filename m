From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Fri, 17 Oct 2014 09:58:24 -0700
Message-ID: <CAHA+R7Od13Bnn3wciLNrA-RsYuYBAjvwAzc20dgGtYT_=EX88w@mail.gmail.com>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:42685 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbaJQQ6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 12:58:25 -0400
Received: by mail-qg0-f52.google.com with SMTP id q108so800762qgd.25
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 09:58:24 -0700 (PDT)
In-Reply-To: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 9:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line
> misses") added a regression for SO_BINDTODEVICE on IPv6.
>
> This is because we still use inet6_iif() which expects that IP6 control
> block is still at the beginning of skb->cb[]
>
> This patch adds tcp_v6_iif() helper and uses it where necessary.
>
> Because __inet6_lookup_skb() is used by TCP and DCCP, we add an iif
> parameter to it.
>

I doubt we still need to store iif in IP6CB() since we have skb->skb_iif,
we can probably just make inet6_iif() be like inet_iif() so that IP6CB()->iif
can be just removed? Does this make any sense to you?

(I have a patch locally since I thought it should be target for net-next.)

Thanks.
