From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH v2] tun: bail out from tun_get_user() if the skb is empty
Date: Wed, 27 Sep 2017 14:58:07 +0200
Message-ID: <CAG_fn=U8Yjxo2LDC3WenGQUOQZwftd3-j4V8Zz5vSMWobx7Bdw@mail.gmail.com>
References: <20170927121649.90557-1-glider@google.com> <1506516168.6617.38.camel@edumazet-glaptop3.roam.corp.google.com>
 <1506516344.6617.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Dmitriy Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Networking <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506516344.6617.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 2:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> On Wed, 2017-09-27 at 05:42 -0700, Eric Dumazet wrote:
>
>> Or something cleaner to avoid copy/paste and focus on proper
>> skb->data[0] access and meaning.
By the way I'm wondering if this is the only place where skb->data is
being accessed.
Isn't eth_type_trans() under IFF_TAP also touching it? Then we need to
check the size earlier.
>> Thanks.
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 3c9985f299503ea65dad7eb3b47e2ab3bef87800..8ddb840687c1bdb24e418261=
2abc9e362624c3e9 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1496,11 +1496,13 @@ static ssize_t tun_get_user(struct tun_struct *t=
un, struct tun_file *tfile,
>>       switch (tun->flags & TUN_TYPE_MASK) {
>>       case IFF_TUN:
>>               if (tun->flags & IFF_NO_PI) {
>> -                     switch (skb->data[0] & 0xf0) {
>> -                     case 0x40:
>> +                     u8 ip_proto =3D skb->len ? (skb->data[0] >> 4) : 0=
;
>
> And name this variable ip_version ;)
>
>
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
