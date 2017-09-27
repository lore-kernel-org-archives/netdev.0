From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] ipv6: do lazy dst->__use update when per cpu dst
 is available
Date: Wed, 27 Sep 2017 11:25:05 -0700
Message-ID: <CAM_iQpUQsj+-TXs5RHExBqzui+sN+VK_YqX1tEzkjsW-N2OLzA@mail.gmail.com>
References: <9d32116e61596b0de6a584b6cf05cae3ce7abb56.1506532145.git.pabeni@redhat.com>
 <CAEA6p_DZxGesjymubWoWx7hQjaZ7Vdchh=cdOW9tAr4F7QvzXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:50145 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752141AbdI0SZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 14:25:26 -0400
Received: by mail-pf0-f174.google.com with SMTP id l188so7660328pfc.6
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 11:25:25 -0700 (PDT)
In-Reply-To: <CAEA6p_DZxGesjymubWoWx7hQjaZ7Vdchh=cdOW9tAr4F7QvzXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 10:44 AM, Wei Wang <weiwan@google.com> wrote:
> Another thing is that I don't really see any places making use of
> dst->__use. So maybe we can also get rid of this dst->__use field?

It is used in rtnl_put_cacheinfo():

        struct rta_cacheinfo ci = {
                .rta_lastuse = jiffies_delta_to_clock_t(jiffies - dst->lastuse),
                .rta_used = dst->__use,
                .rta_clntref = atomic_read(&(dst->__refcnt)),
                .rta_error = error,
                .rta_id =  id,
        };
