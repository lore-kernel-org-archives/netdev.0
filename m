From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 20:47:55 +0000
Message-ID: <yw1xvb98mfes.fsf@unicorn.mansr.com>
References: <yw1x7flonxs5.fsf@unicorn.mansr.com>
	<20151111.142650.1297832998846138251.davem@davemloft.net>
	<yw1x37wcnxcm.fsf@unicorn.mansr.com>
	<20151111.144840.430771235700359719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111.144840.430771235700359719.davem@davemloft.net> (David
	Miller's message of "Wed, 11 Nov 2015 14:48:40 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: M=E5ns Rullg=E5rd <mans@mansr.com>
> Date: Wed, 11 Nov 2015 19:35:05 +0000
>
>>> I don't think it's silly at all.
>>=20
>> I'm sure I read somewhere that the time spent spinning on a lock sho=
uld
>> be kept as small as possible.
>>=20
>>> And unless you can measure it making a difference, don't knock the =
idea.
>>=20
>> I tried using netif_tx_lock() in the IRQ handler instead, and it loc=
ked
>> up solid.  Clearly that was the wrong thing to do.
>
> Oh that's right, it's a BH lock not an IRQ one.
>
> Yet another argument for doing everything in ->poll(), thus making al=
l
> operations outside of NAPI scheduling run in software interrupt
> context, and therefore being able to make use of the TXQ lock for
> this.

Well, I tried calling the DMA restart function from NAPI poll under
netif_tx_lock().  Now it works only as long as there is incoming
traffic.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
