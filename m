From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 12:22:28 +0000
Message-ID: <yw1xa8qkpvy3.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<20151110233448.GA8646@electric-eye.fr.zoreil.com>
	<yw1xio59pdw6.fsf@unicorn.mansr.com>
	<20151110.211121.422193831316296487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151110.211121.422193831316296487.davem@davemloft.net> (David
	Miller's message of "Tue, 10 Nov 2015 21:11:21 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: M=E5ns Rullg=E5rd <mans@mansr.com>
> Date: Wed, 11 Nov 2015 00:40:09 +0000
>
>> When the DMA complete interrupt arrives, the next chain should be
>> kicked off as quickly as possible, and I don't see why that would
>> benefit from being done in napi context.
>
> NAPI isn't about low latency, it's about fairness and interrupt
> mitigation.
>
> You probably don't even realize that all of the TX SKB freeing you do
> in the hardware interrupt handler end up being actually processed by =
a
> scheduled software interrupt anyways.
>
> So you are gaining almost nothing by not doing TX completion in NAPI
> context, whereas by doing so you would be gaining a lot including
> more simplified locking or even the ability to do no locking at all.

TX completion is separate from restarting the DMA, and moving that to
NAPI may well be a good idea.  Should I simply napi_schedule() if the
hardware indicates TX is complete and do the cleanup in the NAPI poll
function?

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
