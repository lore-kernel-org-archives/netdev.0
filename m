From: Jongsung Kim <neidhard.kim@lge.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Tue, 17 Jun 2014 11:38:44 +0900
Message-ID: <539FAA34.9030002@lge.com>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com> <9f5be687-d127-49a4-90ea-c1033505452d@BN1BFFO11FD019.protection.gbl> <539E79F1.1090006@lge.com> <ea57b37f-1f1c-40a0-84a6-46b0b78ec6b4@BY2FFO11FD034.protection.gbl>
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
In-Reply-To: <ea57b37f-1f1c-40a0-84a6-46b0b78ec6b4@BY2FFO11FD034.protection.gbl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/16/2014 11:56 PM, S=C3=B6ren Brinkmann wrote:
> On Mon, 2014-06-16 at 02:00PM +0900, Jongsung Kim wrote:
>> On 06/13/2014 12:44 AM, S=C3=B6ren Brinkmann wrote:
>>> This is now clearing all IRQ flags which is probably not what we wa=
nt
>>> here. This is handling RX only. We still want the non-RX interrupts=
 to go to
>>> the actual interrupt service routing.
>>
>> The ISR(Interrupt Status Register) is read only in the interrupt ser=
vice
>> routine, macb_interrupt. But is partially cleared here and there. Fu=
rther
>> handler-functions decide jobs to be done by reading/checking other s=
tatus
>> registers. (e.g., TSR, RSR) So, clearing the ISR after reading looks=
 not
>> a bad idea.
>
> But you are clearing _all_ interrupt flags in the RX NAPI handler.
> Doesn't that mean we might miss certain events?

Please inspect my patch again. What I did in the macb_poll is removing
statements clearing the Rx-complete interrupt, not clearing all the
interrupts.
