From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Mon, 16 Jun 2014 07:56:27 -0700
Message-ID: <ea57b37f-1f1c-40a0-84a6-46b0b78ec6b4@BY2FFO11FD034.protection.gbl>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com>
 <9f5be687-d127-49a4-90ea-c1033505452d@BN1BFFO11FD019.protection.gbl>
 <539E79F1.1090006@lge.com>
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
In-Reply-To: <539E79F1.1090006@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-06-16 at 02:00PM +0900, Jongsung Kim wrote:
> On 06/13/2014 12:44 AM, S=C3=B6ren Brinkmann wrote:
> > Hi Jongsung,
>=20
> Hi S=C3=B6ren,
>=20
> > Does this interrupt need to be enabled? There is nothing checking
> > that bit and handling this IRQ in the handler, AFAICT. And you solv=
e
> > this by simply clearing the bit. So, I wonder whether not enabling =
this
> > IRQ in the first place would solve things too.
>=20
> The driver actually checks the bit, but does not clear it. Disabling =
the
> "Rx used bit read" interrupt you said may be a solution. However, I t=
hink
> it is the better way to clear the exceptional HW-state rather than ju=
st to
> mask it.
Hmm, I must have missed that.

>=20
> > This is now clearing all IRQ flags which is probably not what we wa=
nt
> > here. This is handling RX only. We still want the non-RX interrupts=
 to go to
> > the actual interrupt service routing.
>=20
> The ISR(Interrupt Status Register) is read only in the interrupt serv=
ice
> routine, macb_interrupt. But is partially cleared here and there. Fur=
ther
> handler-functions decide jobs to be done by reading/checking other st=
atus
> registers. (e.g., TSR, RSR) So, clearing the ISR after reading looks =
not
> a bad idea.
But you are clearing _all_ interrupt flags in the RX NAPI handler.
Doesn't that mean we might miss certain events?

	S=C3=B6ren
