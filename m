From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 09 May 2017 09:56:02 -0700
Message-ID: <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
         <20170508.143557.105629611489969352.davem@davemloft.net>
         <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170508.212211.1291611254198273979.davem@davemloft.net>
         <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35738 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753437AbdEIQ4E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 12:56:04 -0400
Received: by mail-pg0-f67.google.com with SMTP id i63so636617pgd.2
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 09:56:04 -0700 (PDT)
In-Reply-To: <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 09:44 -0700, Cong Wang wrote:

> 
> Eric, how did you produce it?
> I guess it's because of nh_dev which is the only netdevice pointer inside
> fib_info. Let me take a deeper look.
> 

Nothing particular, I am using kexec to boot new kernels, and all my
attempts with your patch included demonstrated the issue.

eth0 is a bonding device, it might matter, I do not know.

We also have some tunnels, but unfortunately I can not provide a setup
that you could use on say a VM.

I can send you the .config if this can help

> >>
> >> I am assuming you are quite confident it is this change?
> >
> > At least, reverting the patch resolves the issue for me.
> >
> > Keeping fib (and their reference to netdev) is apparently too much,
> > we probably need to implement a refcount on the metrics themselves,
> > being stand alone objects.
> 
> I don't disagree, just that it may need to change too much code which
> goes beyond a stable candidate.

Well, your choice, but dealing with a full blown fib and its
dependencies look fragile to me.
