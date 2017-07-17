From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH v2] sctp: don't dereference ptr before leaving _sctp_walk_{params,errors}()
Date: Mon, 17 Jul 2017 11:37:37 +0200
Message-ID: <CAG_fn=WX+ahhp8tokB5K59Q-0z4ok4g+8TMOknTENf2yuvn_1g@mail.gmail.com>
References: <CAG_fn=UU5wT5GuFd6=br2WycHZ+JF6SWTS7=HhNLzDTiDMi-=g@mail.gmail.com>
 <20170714.102312.821784668156442305.davem@davemloft.net> <CAG_fn=XtmFsygwP=o5_pS1fHXUamAy=bib-7DZvX1n9P4MwCgQ@mail.gmail.com>
 <20170714.105431.403659291323482633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        lucien xin <lucien.xin@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714.105431.403659291323482633.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2017 at 7:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Fri, 14 Jul 2017 19:33:54 +0200
>
>> On Fri, Jul 14, 2017 at 7:23 PM, David Miller <davem@davemloft.net> wrot=
e:
>>> From: Alexander Potapenko <glider@google.com>
>>> Date: Fri, 14 Jul 2017 18:33:01 +0200
>>>
>>>> On Fri, Jul 14, 2017 at 5:58 PM, David Miller <davem@davemloft.net> wr=
ote:
>>>>> From: Alexander Potapenko <glider@google.com>
>>>>> Date: Fri, 14 Jul 2017 12:03:29 +0200
>>>>>
>>>>>>  v2: per comment from David Miller, make sure the whole iterator->le=
ngth
>>>>>>      fits into the remaining buffer.
>>>>>
>>>>> Please compile and functionally test your changes:
>>>>>
>>>>> In file included from ./include/linux/compiler.h:58:0,
>>>>>                  from ./include/uapi/linux/stddef.h:1,
>>>>>                  from ./include/linux/stddef.h:4,
>>>>>                  from ./include/uapi/linux/posix_types.h:4,
>>>>>                  from ./include/uapi/linux/types.h:13,
>>>>>                  from ./include/linux/types.h:5,
>>>>>                  from net/sctp/sm_statefuns.c:48:
>>>>> net/sctp/sm_statefuns.c: In function =E2=80=98sctp_sf_do_reconf=E2=80=
=99:
>>>>> ./include/net/sctp/sctp.h:472:24: error: unknown type name =E2=80=98s=
ctp_paramhdr_t=E2=80=99
>>>>>       (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->leng=
th) <\
>>>>>                         ^
>>>> Oops. Fixed.
>>>
>>> Did you functionally test the new version or just do a quick compile
>>> check and resubmit?
>> I've checked that the kernel still works, but unfortunately I couldn't
>> check whether or not this affected the uninit memory, as KMSAN
>> currently works on a fixed kernel revision. The compilation error was
>> actually caused by me failing to test the kernel when porting the fix
>> from that revision to upstream.
>>
>>> I really want you to test this if the logic has been changed.
>> Do you mean any specific tests in addition to, say, running the
>> reproducer on which the uninit use was reported?
>
> I mean the reproducer.
Yes, I've ran the reproducer, and just double-checked that. Sorry for the d=
elay.


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
