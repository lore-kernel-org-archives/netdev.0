From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Tue, 17 Jun 2014 09:54:38 +0200
Message-ID: <539FF43E.2020002@atmel.com>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com> <7e888b59-d27b-49dc-9ffc-1c7d56f11773@BN1AFFO11FD007.protection.gbl> <539FB874.1040003@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hayun Hwang <hwang.hayun@lge.com>,
	"Youngkyu Choi" <youngkyu7.choi@lge.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Jongsung Kim <neidhard.kim@lge.com>,
	=?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <539FB874.1040003@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/06/2014 05:39, Jongsung Kim :
> On 06/17/2014 06:28 AM, S=C3=B6ren Brinkmann wrote:
>> Shouldn't it be sufficient to replace 'MACB_BIT(RCOMP) with 'MACB_RX=
_INT_FLAGS'
>> to clear all the RX IRQ flags.
>=20
> I'm afraid not.
>=20
> You know, this driver initially targeted only GEMs configured with "g=
em_irq_clear_read."
> For this implementation of GEM, the ISR is automatically cleared by r=
eading. The driver
> was designed to operate with the value read from ISR, not with the IS=
R itself.
>=20
> However, there are other GEMs configured without "gem_irq_clear_read,=
" people like you
> and I working with. To support them, they insert similar codes condit=
ionally clearing
> the ISR here and there. Now they are found at 6 places. Not enough ye=
t. Do you want to
> insert another at the end of macb_reset_hw..? Maybe not.

Can't we separate a bit more the implementations of "clear on read" and
"clear on write" so that we do not spread the tests that you are talkin=
g
about all over the place and slower the driver's hot paths?

I am more and more skeptical about the mix of MACB/GEM versions in this
single driver as I realized recently that the old MACB-equipped devices
are behaving strangely and with lower performance figures than in the p=
ast.

Best regards,
--=20
Nicolas Ferre
