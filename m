From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH v2] net/packet: initialize val in packet_getsockopt()
Date: Tue, 25 Apr 2017 18:38:39 +0200
Message-ID: <CAG_fn=VAnDL1UpNe+VQMhSdwgU-cN_PybRLx5-cgW+QdNTmryw@mail.gmail.com>
References: <20170424125914.43270-1-glider@google.com> <20170425.114433.143144279134920277.davem@davemloft.net>
 <CAG_fn=URNuXxc7wEaXd_p7B46RRCYYMTv5rOVc_U1CdvervzPQ@mail.gmail.com> <20170425.123201.1910437101082999848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35094 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1431809AbdDYQil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:38:41 -0400
Received: by mail-qk0-f169.google.com with SMTP id f76so69725534qke.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 09:38:41 -0700 (PDT)
In-Reply-To: <20170425.123201.1910437101082999848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 6:32 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Tue, 25 Apr 2017 18:27:04 +0200
>
>> On Tue, Apr 25, 2017 at 5:44 PM, David Miller <davem@davemloft.net> wrot=
e:
>>> From: Alexander Potapenko <glider@google.com>
>>> Date: Mon, 24 Apr 2017 14:59:14 +0200
>>>
>>>> In the case getsockopt() is called with PACKET_HDRLEN and optlen < 4
>>>> |val| remains uninitialized and the syscall may behave differently
>>>> depending on its value. This doesn't have security consequences (as th=
e
>>>> uninit bytes aren't copied back), but it's still cleaner to initialize
>>>> |val| and ensure optlen is not less than sizeof(int).
>>>>
>>>> This bug has been detected with KMSAN.
>>>>
>>>> Signed-off-by: Alexander Potapenko <glider@google.com>
>>>> ---
>>>> v2: - if len < sizeof(int), make it 0
>>>
>>> No, you should signal an error if the len is too small.
>> According to manpages, only setsockopt() may return EINVAL.
>> Is it ok to change the behavior of getsockopt() to return EINVAL in
>> this case? (I.e. won't we break existing users that don't expect it?)
>
> They are currently getting corrupt data depending upon the endianness,
> so -EINVAL is a serious improvement.
On a second glance getsockopt() already returns -EINVAL in some cases,
so man is already imprecise.


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
