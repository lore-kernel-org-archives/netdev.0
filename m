From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Latest net-next from GIT panic
Date: Wed, 20 Sep 2017 11:36:18 -0700
Message-ID: <CAM_iQpVF3Gf3G=543o8g+5N2dtEL4DcUPN3a6=L8V_G0CXZ65w@mail.gmail.com>
References: <4745525f-18e4-7f69-fe21-8e507e407b33@itcare.pl>
 <d8bbf6c1-20a3-195c-6980-45f29e9f9278@itcare.pl> <2aeb7871-fe89-c714-3355-c5f48651e70c@itcare.pl>
 <15d293fa-0f53-bdca-6358-6a58d1da77af@itcare.pl> <65e2195b-3bd1-c0b4-b474-e07dd08f71b9@itcare.pl>
 <1505877870.29839.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <07bde5d4-fab6-3ef9-f586-403dadbb0a2a@itcare.pl> <8f0b0143-657e-d574-c442-24d3d017bc87@itcare.pl>
 <54d058d4-b9d1-54cb-f064-45cec430fe5d@itcare.pl> <6c073f86-ab71-0a8f-7b9a-91d5ae5da214@itcare.pl>
 <7fee43ee-75b5-c2f5-cf8d-684ceefcd2d1@itcare.pl> <c278dec6-e018-62e0-a613-1fa79741aaab@itcare.pl>
 <cfc04422-51bd-0a28-6a8c-6b57179e8af2@itcare.pl> <3324f95f-7686-81e0-a973-1a9220c918fe@itcare.pl>
 <1505913075.29839.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV8qV8a_yFT0--4Z==FuWda=4EQzKJzHTL+op4S5b9E0A@mail.gmail.com>
 <3c227be7-a954-a406-1987-24e908cf214c@itcare.pl> <CAM_iQpUOOCcES4d_ueK2wizn2oyDZPEzLfWQFu3oOq=BuRzdiw@mail.gmail.com>
 <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37515 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdITSgj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 14:36:39 -0400
Received: by mail-pf0-f194.google.com with SMTP id e69so1503977pfg.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 11:36:39 -0700 (PDT)
In-Reply-To: <1505932231.29839.106.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 11:30 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-09-20 at 11:22 -0700, Cong Wang wrote:
>> but dmesg at this time shows nothing about interfaces or flaps.
>>
>> This is very odd.
>>
>> We only free netdevice in free_netdev() and it is only called when
>> we unregister a netdevice. Otherwise pcpu_refcnt is impossible
>> to be NULL.
>
> If there is a missing dev_hold() or one dev_put() in excess,
> this would allow the netdev to be freed too soon.
>
> -> Use after free.
> memory holding netdev could be reallocated-cleared by some other kernel
> user.
>

Sure, but only unregister could trigger a free. If there is no unregister,
like what Pawel claims, then there is no free, the refcnt just goes to
0 but the memory is still there.
