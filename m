From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH v4] net: don't call strlen on non-terminated string in dev_set_alias()
Date: Tue, 6 Jun 2017 23:15:11 +0200
Message-ID: <CAG_fn=XKLNhKVRf2h6LPm=1j=4cqUQJ=jy25Hfi9+LR8H-UEBQ@mail.gmail.com>
References: <20170606135654.111884-1-glider@google.com> <20170606.163639.1246601020260541080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
        LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606.163639.1246601020260541080.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 6, 2017 at 10:36 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Potapenko <glider@google.com>
> Date: Tue,  6 Jun 2017 15:56:54 +0200
>
>> KMSAN reported a use of uninitialized memory in dev_set_alias(),
>> which was caused by calling strlcpy() (which in turn called strlen())
>> on the user-supplied non-terminated string.
>>
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>
> We should not be allowing non-NULL terminated strings for the
> IFLA_IFALIAS attribute.  It's defined as type NLA_STRING in
> the ifla_policy[] array.
Sorry, I couldn't determine from RFC 2233 whether ifAlias is
zero-terminated or not, but looking at validate_nla() I see that
NLA_STRING is supposed to be such.
I'll check what's going on.

> Please figure out why we aren't enforcing the attribute policy
> properly, rather than adding a workaround.
Guess the string has been previously claimed to be non-terminated
here: https://patchwork.ozlabs.org/patch/996/
> Thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
