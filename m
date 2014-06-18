From: Jongsung Kim <neidhard.kim@lge.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Wed, 18 Jun 2014 17:44:31 +0900
Message-ID: <53A1516F.7010201@lge.com>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com> <7e888b59-d27b-49dc-9ffc-1c7d56f11773@BN1AFFO11FD007.protection.gbl> <539FB874.1040003@lge.com> <539FF43E.2020002@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hayun Hwang <hwang.hayun@lge.com>,
	Youngkyu Choi <youngkyu7.choi@lge.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	=?UTF-8?B?U8O2cmVuIEJyaW5rbWE=?= =?UTF-8?B?bm4=?=
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <539FF43E.2020002@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/17/2014 04:54 PM, Nicolas Ferre wrote:

Hi Nicolas,

> On 17/06/2014 05:39, Jongsung Kim :
>> On 06/17/2014 06:28 AM, S=C3=B6ren Brinkmann wrote:
>>> Shouldn't it be sufficient to replace 'MACB_BIT(RCOMP) with 'MACB_R=
X_INT_FLAGS'
>>> to clear all the RX IRQ flags.
>>
>> I'm afraid not.
>>
>> You know, this driver initially targeted only GEMs configured with "=
gem_irq_clear_read."
>> For this implementation of GEM, the ISR is automatically cleared by =
reading. The driver
>> was designed to operate with the value read from ISR, not with the I=
SR itself.
>>
>> However, there are other GEMs configured without "gem_irq_clear_read=
," people like you
>> and I working with. To support them, they insert similar codes condi=
tionally clearing
>> the ISR here and there. Now they are found at 6 places. Not enough y=
et. Do you want to
>> insert another at the end of macb_reset_hw..? Maybe not.
>=20
> Can't we separate a bit more the implementations of "clear on read" a=
nd
> "clear on write" so that we do not spread the tests that you are talk=
ing
> about all over the place and slower the driver's hot paths?

I see. I'll revise my patch. Thank you for your advice.

Regards,
Jongsung
