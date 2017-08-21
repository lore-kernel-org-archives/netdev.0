From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] tcp: Remove unnecessary dst check in
 tcp_conn_request.
Date: Mon, 21 Aug 2017 07:56:02 -0700
Message-ID: <1503327362.2499.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502938966-6345-1-git-send-email-xiangxia.m.yue@gmail.com>
         <1502938966-6345-2-git-send-email-xiangxia.m.yue@gmail.com>
         <20170819.212524.1982304186024322688.davem@davemloft.net>
         <CAMDZJNW_nqUm7LaKy5GJBKMhKV6GeZS_yAnUy+gT68NatT_EZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35415 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753206AbdHUO4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 10:56:05 -0400
Received: by mail-pg0-f65.google.com with SMTP id m133so4808479pga.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 07:56:05 -0700 (PDT)
In-Reply-To: <CAMDZJNW_nqUm7LaKy5GJBKMhKV6GeZS_yAnUy+gT68NatT_EZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top post.

On Mon, 2017-08-21 at 21:24 +0800, Tonghao Zhang wrote:
> Thanks,  yes  this is a bug. I found this bug exists from 3.17~ 4.13.
> The commit is d94e0417
> 

This bug was there at the beginning of git tree.


> One question:  should I send a patch for each kernel version because
> code conflicts ?
> 
> a patch for v4.12
> a patch for v4.11
> a patch for v4.10~v4.7
> a patch for v4.6~v3.17
> 
> and
> a patch for  net-next, because tcp_tw_recycle has been removed.
> 

Given this bug only would matter if syncookies are disabled, I would not
bother and only target net-next. This does not look serious enough to
deserve backports to stable versions.


> Thanks very much.
> 
> On Sun, Aug 20, 2017 at 12:25 PM, David Miller <davem@davemloft.net> wrote:
> > From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> > Date: Wed, 16 Aug 2017 20:02:45 -0700
> >
> >> Because we remove the tcp_tw_recycle support in the commit
> >> 4396e46187c ('tcp: remove tcp_tw_recycle') and also delete
> >> the code 'af_ops->route_req' for sysctl_tw_recycle in tcp_conn_request.
> >> Now when we call the 'af_ops->route_req', the dist always is
> >> NULL, and we remove the unnecessay check.
> >>
> >> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> >
> > This is a bug actually, rather than something to paper over
> > by removing the check.
> >
> > Code earlier in this function needs a proper 'dst' in order to operate
> > properly.
> >
> > There is a call to tcp_peer_is_proven() which must have a proper route
> > to make the determination yet it will always be NULL.
> >
> > Please investigate what the code is doing and how a test became
> > "unnecessary" over time before blindly removing it, thank you.
