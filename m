From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] net: initialize msg.msg_flags in recvfrom
Date: Tue, 7 Mar 2017 16:24:04 +0100
Message-ID: <CAG_fn=VyD6eNP6k-4q16ydy4h7VKWxQY9Pa9We_28GWQezVZUw@mail.gmail.com>
References: <20170307135810.90371-1-glider@google.com> <1488896800.9415.398.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488896800.9415.398.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 7, 2017 at 3:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
> On Tue, 2017-03-07 at 14:58 +0100, Alexander Potapenko wrote:
>> KMSAN (KernelMemorySanitizer, a new error detection tool) reports use
>> of uninitialized memory in put_cmsg()):
>
> I would prefer that you do not put the stack trace in the changelog,
> same for the reproducer since this has little value in understanding the
> impact.
Understood.
Should be ok to put the report/reproducer below the triple dash, right?

> It looks like a false positive, but you do not say.
Ah, now I see.
Irrespective of the value of (MSG_CMSG_COMPAT & msg->msg_flags) the
code will return 0 either directly from put_cmsg(), or from
put_cmsg_compat().
I wouldn't call this a false positive, as KMSAN can't possibly know
that both branches taken depending on the uninitialized condition are
safe.
But I can imagine this to be less of an problem to the code owners who
do know that :)

> recvmsg() does not care about msg.msg_flags, only KMSAN.
>
> (The important part is that msg.msg_control and msg.msg_controllen are
> 0)
>
> Fine to avoid the false positive, but better be explicit in the
> changelog and says there is no visible effect for this bug.
Ok, I'll change the description.
> If there is a visible effect, please state so instead of technical
> details.
>
> We try to reduce S/N in the changelogs ;)
>
> Thanks a lot !
>
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
