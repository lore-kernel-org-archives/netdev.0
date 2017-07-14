From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] ipv6: initialize treq->txhash in cookie_v6_check()
Date: Fri, 14 Jul 2017 19:35:02 +0200
Message-ID: <CAG_fn=XZVGc6Viw2ngQp7kMZ50PK5se_PXynjVKYr9cLywU58g@mail.gmail.com>
References: <20170714165453.112098-1-glider@google.com> <CADVnQynZUh+4kU9Fdq8crAmi-j8BbErid=mJQ6B-WVXDGU2VQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQynZUh+4kU9Fdq8crAmi-j8BbErid=mJQ6B-WVXDGU2VQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 7:04 PM, Neal Cardwell <ncardwell@google.com> wrote=
:
> On Fri, Jul 14, 2017 at 12:54 PM, Alexander Potapenko <glider@google.com>=
 wrote:
>> KMSAN reported use of uninitialized memory in skb_set_hash_from_sk(),
>> which originated from the TCP request socket created in
>> cookie_v6_check():
> ...
>> --- a/net/ipv6/syncookies.c
>> +++ b/net/ipv6/syncookies.c
>> @@ -216,6 +216,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct=
 sk_buff *skb)
>>         treq->rcv_isn =3D ntohl(th->seq) - 1;
>>         treq->snt_isn =3D cookie;
>>         treq->ts_off =3D 0;
>> +       treq->txhash =3D 0;
>>
>>         /*
>>          * We need to lookup the dst_entry to get the correct window siz=
e.
>
> I would have thought that the same fix is needed in the corresponding
> line in cookie_v4_check() in net/ipv4/syncookies.c? (I do not see
> txhash being initialized for the IPv4 side.) If it's not needed for
> some reason, then it would be worth a comment in the commit
> description to explain why not.
Most certainly it is needed. I haven't seen reports for that in the
wild and couldn't forge a repro triggering the bug in IPv4, but I'll
give it another shot.
> thanks,
> neal



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
