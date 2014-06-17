From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Mon, 16 Jun 2014 20:50:17 -0700
Message-ID: <0f1d404c-89a7-4bbd-99ff-973d4f26d2c6@BY2FFO11FD005.protection.gbl>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com>
 <9f5be687-d127-49a4-90ea-c1033505452d@BN1BFFO11FD019.protection.gbl>
 <539E79F1.1090006@lge.com>
 <ea57b37f-1f1c-40a0-84a6-46b0b78ec6b4@BY2FFO11FD034.protection.gbl>
 <539FAA34.9030002@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hayun Hwang <hwang.hayun@lge.com>,
	Youngkyu Choi <youngkyu7.choi@lge.com>
To: Jongsung Kim <neidhard.kim@lge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <539FAA34.9030002@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-06-17 at 11:38AM +0900, Jongsung Kim wrote:
> On 06/16/2014 11:56 PM, S=C3=B6ren Brinkmann wrote:
> > On Mon, 2014-06-16 at 02:00PM +0900, Jongsung Kim wrote:
> >> On 06/13/2014 12:44 AM, S=C3=B6ren Brinkmann wrote:
> >>> This is now clearing all IRQ flags which is probably not what we =
want
> >>> here. This is handling RX only. We still want the non-RX interrup=
ts to go to
> >>> the actual interrupt service routing.
> >>
> >> The ISR(Interrupt Status Register) is read only in the interrupt s=
ervice
> >> routine, macb_interrupt. But is partially cleared here and there. =
=46urther
> >> handler-functions decide jobs to be done by reading/checking other=
 status
> >> registers. (e.g., TSR, RSR) So, clearing the ISR after reading loo=
ks not
> >> a bad idea.
> >
> > But you are clearing _all_ interrupt flags in the RX NAPI handler.
> > Doesn't that mean we might miss certain events?
>=20
> Please inspect my patch again. What I did in the macb_poll is removin=
g
> statements clearing the Rx-complete interrupt, not clearing all the
> interrupts.

Oh, you're right. I misread the patch, sorry. The call to macb_read_isr=
 was
already a different hunk.
Why is clearing those bits removed? It's probably not a big hit, but it=
 might
result in a pointless interrupt which could be avoided. But it should
probably clear all RX interrupts - MACB_RX_INT_FLAGS - instead of just =
RCOMP.
=46or clear-on-read implementations it shouldn't make a difference.

And in the if-condition in that new helper, I'd add '&& status' to
avoid writing back zeros.

	Thanks,
	S=C3=B6ren
