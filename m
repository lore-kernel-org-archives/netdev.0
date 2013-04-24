From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Wed, 24 Apr 2013 14:36:15 +0200
Message-ID: <CAMuHMdXzNMt63pOa3136Fmrs2tPQzh5SGe2YfCn+yGtzOyMqoQ@mail.gmail.com>
References: <CA+55aFwogFL=nm=YHwARcz9OTRBdWEDPG0xcqM-H3k-VZTOZPQ@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B71F2@saturn3.aculab.com>
	<CA+55aFxvpcF7+dyy5d3+JP4Wfv90zPsRVtEhNG9Pky5gWTm_Pg@mail.gmail.com>
	<20130423.133732.2222922370397287096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David.Laight@aculab.com, Ingo Molnar <mingo@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Theodore Ts'o" <tytso@mit.edu>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ext4@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130423.133732.2222922370397287096.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 23, 2013 at 7:37 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Tue, 23 Apr 2013 08:42:49 -0700
>
>> An explicit cast fixes it, and shows that you were aware of the issu=
e:
>>
>>    foo &=3D ~(foo_t)bar;
>>
>> and gcc will generate the right logic. Of course, casts then have
>> their own problems, which your thing avoids (as would just having a
>> "andn" operation in C)
>
> I just want to mention that this is dangerous in different ways, we
> just recently got a patch in the networking that removed such a cast.
> The problem is when the cast narrows, f.e.:
>
>         ~(u8)0
>
> doesn't do what you think it does.  That doesn't evaluate to 0xff.

This is the definition of MAC802154_CHAN_NONE?

We _should_ have noticed this earlier, as old gcc (e.g. 4.1.2) emits a
warning when comparing it to a u8:

net/mac802154/monitor.c: In function =E2=80=98mac802154_monitor_xmit=E2=
=80=99:
net/mac802154/monitor.c:49: warning: comparison is always false due to
limited range of data type
net/mac802154/wpan.c: In function =E2=80=98mac802154_wpan_xmit=E2=80=99=
:
net/mac802154/wpan.c:323: warning: comparison is always false due to
limited range of data type

Interestingly, none of this is seen in the build logs of the linux-next=
 build
service, which uses gcc 4.2.3, 4.2.4, 4.5.1, and 4.6...

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
