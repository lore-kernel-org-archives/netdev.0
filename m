From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] net: speedup netns create/delete time
Date: Tue, 26 Sep 2017 08:22:39 -0700
Message-ID: <33E69A03-6594-423A-86E6-02029046BE7D@gmail.com>
References: <20170919232709.14690-1-edumazet@google.com> <8edb310a-562d-bff1-0482-64314833e722@mellanox.com> <CANn89i+LE6He_E3VHwUTpLAVW+uUGo+FPs_zg1bs4P3CVcCL6Q@mail.gmail.com> <266d30e7-5164-48e8-b802-56bb93558823@mellanox.com> <CANn89iJ4io_gX-V8A4hE04cH=czGZYs8WGBOpaiBpWMMHOgVVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Yonatan Cohen <yonatanc@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Eric Dumazet <edumazet@google.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36578 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964826AbdIZPWq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:22:46 -0400
Received: by mail-pg0-f65.google.com with SMTP id d8so6948568pgt.3
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 08:22:46 -0700 (PDT)
In-Reply-To: <CANn89iJ4io_gX-V8A4hE04cH=czGZYs8WGBOpaiBpWMMHOgVVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 26, 2017 8:13:21 AM PDT, Eric Dumazet <edumazet@google=2Ecom> =
wrote:
>On Tue, Sep 26, 2017 at 8:04 AM, Tariq Toukan <tariqt@mellanox=2Ecom>
>wrote:
>>
>>
>> On 26/09/2017 3:51 PM, Eric Dumazet wrote:
>>>
>>> On Tue, Sep 26, 2017 at 4:21 AM, Tariq Toukan <tariqt@mellanox=2Ecom>
>wrote:
>>>>
>>>>
>>>> Hi Eric,
>>>>
>>>> We see a regression introduced in this series, specifically in the
>>>> patches
>>>> touching lib/kobject_uevent=2Ec=2E
>>>> We tried to figure out what is wrong there, but couldn't point it
>out=2E
>>>>
>>>> Bug is that mlx4 driver restart fails, because mlx4_core is still
>in use=2E
>>>> According to module dependencies, both mlx4_en and mlx4_ib should
>have
>>>> been
>>>> unloaded at this point
>>>> Please see log below=2E
>>>>
>>>> This looks to be some kind of a race, as the repro is not
>deterministic=2E
>>>> Probably the en/ib modules are now mistakenly reloaded=2E
>>>>
>>>> Any idea what could this be?
>>>>
>>>> Regards,
>>>> Tariq
>>>>
>>>>
>>>> [root@reg-l-vrt-41016-009 ~]# /etc/init=2Ed/openibd stop
>>>> Unloading HCA driver:                                      [  OK  ]
>>>> [root@reg-l-vrt-41016-009 ~]# /etc/init=2Ed/openibd start
>>>> Loading HCA driver and Access Layer:                       [  OK  ]
>>>> [root@reg-l-vrt-41016-009 ~]# /etc/init=2Ed/openibd stop
>>>> Unloading mlx4_core                                        [FAILED]
>>>> rmmod: ERROR: Module mlx4_core is in use
>>>
>>> I have absolutely no idea=2E Please bisect=2E
>>
>> We previously saw a similar issue, that was reported in mailing list=2E
>> Dmitry Torokhov suggested the following fix:
>> https://lkml=2Eorg/lkml/2017/9/12/523
>>
>> And indeed, it solved the issue=2E
>>
>> We kept the suggested patch in our internal branch, and rebased=2E
>> Issue appeared again once your series was accepted=2E
>>
>> By bisecting, we see that the issue re-appears in this patch:
>> 4a336a23d619 kobject: copy env blob in one go
>>
>>>
>>> Are you really using netns in the first place ?
>>
>> No=2E But seems like it still affects the modules load/unload=2E
>>
>> Regards,
>> Tariq
>
>Ah this makes sense now=2E
>
>Dmitry Torokhov hack breaks the assumption I used in my patch=2E
>
>Since it is not upstream yet, I believe that it will need more work
>before being in a proper state=2E

It is in Greg's tree where all kobject patches should go through as far as=
 I know=2E


Thanks=2E

--=20
Dmitry
