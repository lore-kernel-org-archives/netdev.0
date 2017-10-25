From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Wed, 25 Oct 2017 14:24:02 -0400
Message-ID: <CAF=yD-JFjjA=2T7HermH2GygfHinyW+ZC5v+Di7M4V_Fg5paHg@mail.gmail.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
 <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com> <CACT4Y+bjzzCv3LSxK12C1xB8GfR3UYCrX_5phRYJ8fpxh9vcvQ@mail.gmail.com>
 <CAF=yD-K76TMjHiYRTRAnxM-x4LBcUDY+27WX477HW6kG=L_aZw@mail.gmail.com> <D2AD6D5B-3A05-48E7-A999-DECAB18A4649@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Wei Wei <dotweiba@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D2AD6D5B-3A05-48E7-A999-DECAB18A4649@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 21, 2017 at 9:56 PM, Wei Wei <dotweiba@gmail.com> wrote:
> I have uploaded the VM core dump [1]. And I don=E2=80=99t know if these l=
ogs are helpful in the case of
> failing to get the C reproducer currently.
>
> [1] https://github.com/dotweiba/skb_clone_atomic_inc_bug/blob/master/vmco=
re.gz

Thanks. So this would be the atomic_inc on shb_shinfo(skb)->dataref, which
matches the __ll_sc_atomic_add in Mark's trace.

Debugging with crash shows 0xffff800071bb3180 and 0xffff800071bb2c80
to be valid skbuffs of len 40, no sk, both pointing to the same head.

That is indeed unaligned:  head =3D 0xffff8000327c80c9 "", end =3D 256, giv=
ing
skb_shared_info at 0xffff8000327c81c9 and  &skb_shared_info(skb)->dataref
at 0xffff8000327c81c9 + 36 =3D=3D 0xffff8000327c81ed
