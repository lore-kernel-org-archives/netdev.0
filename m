From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH v2] iproute2: build nsid-name cache only for commands that
 need it
Date: Fri, 16 Sep 2016 12:23:54 +0300
Message-ID: <CAMw6YJJuoA+Z_DQx8iSEkrurB4ZZN9MePtHEeW=q7t5aDvmSAA@mail.gmail.com>
References: <20160916072225.GA10536@toys.tundra.dog-lvm.novalocal> <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Anton Aksola <aakso@iki.fi>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36301 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754364AbcIPJX4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:23:56 -0400
Received: by mail-wm0-f66.google.com with SMTP id b184so2737426wma.3
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 02:23:56 -0700 (PDT)
In-Reply-To: <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 12:13 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 16/09/2016 =C3=A0 09:22, Anton Aksola a =C3=A9crit :
>> The calling of netns_map_init() before command parsing introduced
>> a performance issue with large number of namespaces.
>>
>> As commands such as add, del and exec do not need to iterate through
>> /var/run/netns it would be good not no build the cache before executing
>> these commands.
>>
>> Example:
>> unpatched:
>> time seq 1 1000 | xargs -n 1 ip netns add
>>
>> real    0m16.832s
>> user    0m1.350s
>> sys    0m15.029s
>>
>> patched:
>> time seq 1 1000 | xargs -n 1 ip netns add
>>
>> real    0m3.859s
>> user    0m0.132s
>> sys    0m3.205s
>>
>> Signed-off-by: Anton Aksola <aakso@iki.fi>
>> ---
> There is still some differences:
> $ cat test.batch
> netns add foo
> netns set foo 1234
> netns list-id
>
> Before your patch:
> $ ip -b test.batch
> nsid 1234 (iproute2 netns name: foo)
>
> After your patch:
> $ ip -b test.batch
> nsid 1234

Would it be useful to add test for this case into testsuite/ ?

Regards,
Vadim Kochan
