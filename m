From: Jongsung Kim <neidhard.kim@lge.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Mon, 16 Jun 2014 14:00:33 +0900
Message-ID: <539E79F1.1090006@lge.com>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com> <9f5be687-d127-49a4-90ea-c1033505452d@BN1BFFO11FD019.protection.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hayun Hwang <hwang.hayun@lge.com>,
	Youngkyu Choi <youngkyu7.choi@lge.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9f5be687-d127-49a4-90ea-c1033505452d@BN1BFFO11FD019.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2014 12:44 AM, S=C3=B6ren Brinkmann wrote:
> Hi Jongsung,

Hi S=C3=B6ren,

> Does this interrupt need to be enabled? There is nothing checking
> that bit and handling this IRQ in the handler, AFAICT. And you solve
> this by simply clearing the bit. So, I wonder whether not enabling th=
is
> IRQ in the first place would solve things too.

The driver actually checks the bit, but does not clear it. Disabling th=
e
"Rx used bit read" interrupt you said may be a solution. However, I thi=
nk
it is the better way to clear the exceptional HW-state rather than just=
 to
mask it.

> This is now clearing all IRQ flags which is probably not what we want
> here. This is handling RX only. We still want the non-RX interrupts t=
o go to
> the actual interrupt service routing.

The ISR(Interrupt Status Register) is read only in the interrupt servic=
e
routine, macb_interrupt. But is partially cleared here and there. Furth=
er
handler-functions decide jobs to be done by reading/checking other stat=
us
registers. (e.g., TSR, RSR) So, clearing the ISR after reading looks no=
t
a bad idea.

Jongsung
