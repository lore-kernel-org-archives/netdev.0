From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2] drivers: net: xgene: Rewrite loop in xgene_enet_ecc_init()
Date: Thu, 23 Oct 2014 09:06:48 +0200
Message-ID: <CAMuHMdXwc1nBJx_uq4NxueF67bFLkF3XnPgpW-X6pYom1fHTUQ@mail.gmail.com>
References: <1413963581-24019-1-git-send-email-geert@linux-m68k.org>
	<20141022.153436.93475594748933547.davem@davemloft.net>
	<CAMuHMdXJs=+SpB07t0a+LRWX_TGUnUmQi3P-aExFzmbm_j0fow@mail.gmail.com>
	<20141022.161257.290251379136182774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Iyappan Subramanian <isubramanian@apm.com>, kchudgar@apm.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141022.161257.290251379136182774.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 22, 2014 at 10:12 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: Geert Uytterhoeven <geert@linux-m68k.org>
> Date: Wed, 22 Oct 2014 21:50:06 +0200
>
>> On Wed, Oct 22, 2014 at 9:34 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Geert Uytterhoeven <geert@linux-m68k.org>
>>> Date: Wed, 22 Oct 2014 09:39:41 +0200
>>>
>>>> drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c: In function =E2=
=80=98xgene_enet_ecc_init=E2=80=99:
>>>> drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c:126: warning: =E2=
=80=98data=E2=80=99 may be used uninitialized in this function
>>>>
>>>> Depending on the arbitrary value on the stack, the loop may termin=
ate
>>>> too early, and cause a bogus -ENODEV failure.
>>>>
>>>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>>>> ---
>>>> v2: Rewrite the loop instead of pre-initializing data.
>>>
>>> I hate to be a pest, but like the other patch of your's I think
>>> a do { } while() works best here because the intent is clearly
>>> to run the loop at least once, right?
>>
>> I wanted to avoid checking for "data !=3D ~0U" twice: once to abort =
the loop,
>> and once to check if a timeout happened.
>
> Hmmm:
>
>         do {
>                 usleep_range(...);
>                 data =3D ...();
>                 if (data =3D=3D ~0)
>                         return 0;
>         } while (++i < 10);
>
>         netdev_err(...);
>         return -ENODEV;
>
> Why would you have to check data twice?

Yes, that would work to.

=46eel free to do s/for (i =3D 0; i < 10; i++)/do/ and s/}/} while (++i=
 < 10);/

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
