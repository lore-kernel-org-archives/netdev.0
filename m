From: Jongsung Kim <neidhard.kim@lge.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Tue, 17 Jun 2014 12:39:32 +0900
Message-ID: <539FB874.1040003@lge.com>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com> <7e888b59-d27b-49dc-9ffc-1c7d56f11773@BN1AFFO11FD007.protection.gbl>
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
In-Reply-To: <7e888b59-d27b-49dc-9ffc-1c7d56f11773@BN1AFFO11FD007.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/17/2014 06:28 AM, S=C3=B6ren Brinkmann wrote:
> Shouldn't it be sufficient to replace 'MACB_BIT(RCOMP) with 'MACB_RX_=
INT_FLAGS'
> to clear all the RX IRQ flags.

I'm afraid not.

You know, this driver initially targeted only GEMs configured with "gem=
_irq_clear_read."
=46or this implementation of GEM, the ISR is automatically cleared by r=
eading. The driver
was designed to operate with the value read from ISR, not with the ISR =
itself.

However, there are other GEMs configured without "gem_irq_clear_read," =
people like you
and I working with. To support them, they insert similar codes conditio=
nally clearing
the ISR here and there. Now they are found at 6 places. Not enough yet.=
 Do you want to
insert another at the end of macb_reset_hw..? Maybe not.

Jongsung
