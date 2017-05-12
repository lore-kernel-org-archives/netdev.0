From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Thu, 11 May 2017 17:07:15 -0700
Message-ID: <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170508.143557.105629611489969352.davem@davemloft.net> <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170508.212211.1291611254198273979.davem@davemloft.net> <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
 <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
 <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
 <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35243 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdELAHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 20:07:37 -0400
Received: by mail-wm0-f44.google.com with SMTP id b84so4059610wmh.0
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 17:07:36 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 10, 2017 at 12:51 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         Oh, well, the sockets can hold cached dst.
> But if the promise is that rt->fi is used only as
> reference to metrics we have to find a way to drop
> the dev references at NETDEV_UNREGISTER time. If you
> set nh_dev to NULL then all lookups should check it
> for != NULL. The sockets will not walk NHs via rt->fi,
> i.e. the route lookups will get valid res.fi from trees,
> so it may work in this way.
>

So, if I understand you correctly it is safe to NULL'ing
nh_dev in NETDEV_UNREGISTER_FINAL, right?

If still not, how about transfer nh_dev's to loopback_dev
too in NETDEV_UNREGISTER? Like we transfer dst->dev.

I don't want to touch the fast path to check for NULL, as
it will change more code and slow down performance.

Thanks.
