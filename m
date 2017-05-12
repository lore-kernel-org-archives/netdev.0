From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Thu, 11 May 2017 21:55:48 -0700
Message-ID: <1494564948.7796.128.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170508.143557.105629611489969352.davem@davemloft.net>
         <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170508.212211.1291611254198273979.davem@davemloft.net>
         <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
         <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
         <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
         <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
         <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
         <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg>
         <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
         <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg>
         <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
         <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33571 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751370AbdELEzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 00:55:50 -0400
Received: by mail-pg0-f65.google.com with SMTP id s62so6149524pgc.0
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 21:55:50 -0700 (PDT)
In-Reply-To: <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-05-11 at 18:22 -0700, Cong Wang wrote:
> On Thu, May 11, 2017 at 5:07 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > So, if I understand you correctly it is safe to NULL'ing
> > nh_dev in NETDEV_UNREGISTER_FINAL, right?
> >
> > If still not, how about transfer nh_dev's to loopback_dev
> > too in NETDEV_UNREGISTER? Like we transfer dst->dev.
> >
> > I don't want to touch the fast path to check for NULL, as
> > it will change more code and slow down performance.
> 
> Finally I come up with the attached patch. Please let me know if
> I still miss anything.

You have not addressed my prior feedback, unless I am mistaken ?

fib_route_seq_show() and others do not expect fi->fib_dev suddenly
becoming NULL. 

RCU contract is more complicated than simply adding rcu grace period
before delete.

Thanks.
