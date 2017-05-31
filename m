From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] net: rtnetlink: bail out from rtnl_fdb_dump() on parse error
Date: Wed, 31 May 2017 10:56:47 +0200
Message-ID: <CAG_fn=WNnkmZ8CXqM6w7p_kmhh8Tys1HjgkfASYjvEZ2iie0hg@mail.gmail.com>
References: <20170523112028.132630-1-glider@google.com> <20170524.153224.1230164587077679673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524.153224.1230164587077679673.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I've noticed that the upstream patch:
https://github.com/torvalds/linux/commit/0ff50e83b5122e836ca492fefb11656b22=
5ac29c
contains the KMSAN report and the repro, despite I've put them under
the triple dash (IIRC Eric told me I shouldn't bloat the patch
descriptions with that information). Did I mess it up somehow?

Alex

On Wed, May 24, 2017 at 9:32 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Tue, 23 May 2017 13:20:28 +0200
>
>> rtnl_fdb_dump() failed to check the result of nlmsg_parse(), which led
>> to contents of |ifm| being uninitialized because nlh->nlmsglen was too
>> small to accommodate |ifm|. The uninitialized data may affect some
>> branches and result in unwanted effects, although kernel data doesn't
>> seem to leak to the userspace directly.
>>
>> The bug has been detected with KMSAN and syzkaller.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>
> Applied, thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
