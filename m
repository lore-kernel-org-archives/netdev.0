From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: igmp: fix a use after free
Date: Thu, 8 Jun 2017 17:59:32 -0700
Message-ID: <CAM_iQpVu+sF4zGhGCYDV6J-+rN69zuMGGvGJpLajhYS-QfdUfQ@mail.gmail.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
 <1496929425.736.73.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADvbK_fWOFWZxKc8gbzeDeU1ALq5GHxKvoGsPt+GsdAP0a601w@mail.gmail.com> <1496954011.736.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Xin Long <lucien.xin@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37558 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751405AbdFIA7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 20:59:54 -0400
Received: by mail-wm0-f51.google.com with SMTP id d73so40732423wma.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 17:59:54 -0700 (PDT)
In-Reply-To: <1496954011.736.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 1:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I mentioned (in https://lkml.org/lkml/2017/5/31/619 ) that we might need
> to defer freeing after rcu grace period but for some reason decided it
> was not needed.

This one makes sense, it is the second time I saw the use-after-free
in igmp code, both are because we don't respect the RCU rule to free
an element in the list.

>
> What about :

But not sure if all ip_ma_put() callers want ip_mc_clear_src().
