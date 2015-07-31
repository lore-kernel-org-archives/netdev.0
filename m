From: Florian Fainelli <florian@alphacore.org>
Subject: Re: [PATCH net-next 0/3] net: Switch tag HW extraction/insertion
Date: Thu, 30 Jul 2015 18:51:57 -0700
Message-ID: <55BAD4BD.20405@alphacore.org>
References: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>	<20150730.141935.723435302404122784.davem@davemloft.net> <20150730.155124.2216613161860898066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150730.155124.2216613161860898066.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/07/15 15:51, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 30 Jul 2015 14:19:35 -0700 (PDT)
>=20
>> This looks fine, series applied, thanks.
>=20
> I think your control block is too large, you'll need to rework this
> somehow.

So napi_gro_cb really is 48 bytes on 64-bits architectures (had not
realized it was so big).

What would you recommend to do here considering that this driver is
currently used on 32-bits platforms, but I see no reason why someone
would no want to use this feature on a 64-bit platform, yet we are
competing with napi_gro_cb, and adding a new skbuff member is pretty
much a no-no? Would it be acceptable to have a new member which is ifde=
f
CONFIG_NET_DSA_TAG_BRCM?

=46WIW, this does provide a small 2-3% throughput increase for RX.

>=20
> In function =E2=80=98dsa_copy_brcm_tag=E2=80=99,
>     inlined from =E2=80=98bcm_sysport_desc_rx=E2=80=99 at drivers/net=
/ethernet/broadcom/bcmsysport.c:707:4,
>     inlined from =E2=80=98bcm_sysport_poll=E2=80=99 at drivers/net/et=
hernet/broadcom/bcmsysport.c:864:12:
> include/linux/compiler.h:447:38: error: call to =E2=80=98__compiletim=
e_assert_2016=E2=80=99 declared with attribute error: BUILD_BUG_ON fail=
ed: sizeof(skb->cb) - sizeof(struct napi_gro_cb) < BRCM_TAG_LEN
>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__=
)
>                                       ^
> include/linux/compiler.h:430:4: note: in definition of macro =E2=80=98=
__compiletime_assert=E2=80=99
>     prefix ## suffix();    \
>     ^
> include/linux/compiler.h:447:2: note: in expansion of macro =E2=80=98=
_compiletime_assert=E2=80=99
>   _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__=
)
>   ^
> include/linux/bug.h:50:37: note: in expansion of macro =E2=80=98compi=
letime_assert=E2=80=99
>  #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
>                                      ^
> include/linux/bug.h:74:2: note: in expansion of macro =E2=80=98BUILD_=
BUG_ON_MSG=E2=80=99
>   BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
>   ^
> include/linux/netdevice.h:2016:2: note: in expansion of macro =E2=80=98=
BUILD_BUG_ON=E2=80=99
>   BUILD_BUG_ON(sizeof(skb->cb) - sizeof(struct napi_gro_cb) < BRCM_TA=
G_LEN);
>   ^
> scripts/Makefile.build:264: recipe for target 'drivers/net/ethernet/b=
roadcom/bcmsysport.o' failed
>=20


--=20
=46lorian
