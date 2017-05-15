From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Mon, 15 May 2017 15:13:24 -0700
Message-ID: <CAM_iQpWAjTJL54h_Pdg3DigjEK4kQdSz0pmAks6ByoP67ROOFg@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
 <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
 <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
 <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
 <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg> <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com>
 <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg> <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com>
 <alpine.LFD.2.20.1705152317090.4002@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36780 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751268AbdEOWNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 18:13:47 -0400
Received: by mail-wm0-f43.google.com with SMTP id u65so97318377wmu.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 15:13:46 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1705152317090.4002@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 1:37 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         Any user that does not set FIB_LOOKUP_NOREF
> will need nh_dev refcounts. The assumption is that the
> NHs are accessed, who knows, may be even after RCU grace
> period. As result, we can not use dev_put on NETDEV_UNREGISTER.
> So, we should check if there are users that do not
> set FIB_LOOKUP_NOREF, at first look, I don't see such ones
> for IPv4.

I see, although we do have FIB_LOOKUP_NOREF set all the times,
there are other places we hold fib_clntref too, for example
mlxsw_sp_router_fib_event_work(), it actually uses nh_dev too...

So I am afraid moving dev_put() to fib_release_info() is not a solution
here. I have to rethink about it.
