From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 10:59:07 -0700
Message-ID: <1505930347.29839.104.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
         <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl>
         <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
         <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl>
         <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
         <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
         <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl>
         <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
         <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl>
         <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
         <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl>
         <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
         <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl>
         <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
         <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpV8qV8a_yFT0--4Z==FuWda=4EQzKJzHTL+op4S5b9E0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
        Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:44126 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750938AbdITR7K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 13:59:10 -0400
Received: by mail-pf0-f172.google.com with SMTP id e1so1909195pfk.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 10:59:10 -0700 (PDT)
In-Reply-To: <CAM_iQpV8qV8a_yFT0--4Z==FuWda=4EQzKJzHTL+op4S5b9E0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-20 at 10:50 -0700, Cong Wang wrote:
> On Wed, Sep 20, 2017 at 6:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Sorry for top-posting, but this is to give context to Wei, since Pawel
> > used a top posting way to report his bisection.
> >
> > Wei, can you take a look at Pawel report ?
> >
> > Crash happens in dst_destroy() at following :
> >
> > if (dst->dev)
> >      dev_put(dst->dev); <<CRASH>>
> >
> >
> > dst->dev is not NULL, but netdev->pcpu_refcnt is NULL
> >
> > 65 ff 08                decl   %gs:(%rax)   // CRASH since rax = NULL
> >
> >
> >
> > Pawel, please share your netdevices and routing setup  ?
> 
> Looks like a double dev_put() on some dev...
> 
> Pawel, do you have any idea how this is triggered? Does your
> test try to remove some network device? If so which one?
> I noticed you have at least multiple vlan, bond and ixgbe
> devices.

Or a missing dev_hold() somewhere.
