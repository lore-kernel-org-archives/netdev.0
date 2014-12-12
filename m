From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: Re: [PATCH v2 1/1] net/macb: add TX multiqueue support for gem
Date: Fri, 12 Dec 2014 09:24:03 +0100
Message-ID: <548AA623.9070304@atmel.com>
References: <cover.1418291637.git.cyrille.pitchen@atmel.com>	<87a3098203ee6eaa7a60607713a293d3258e2b58.1418291637.git.cyrille.pitchen@atmel.com> <20141211203103.4191887a@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141211203103.4191887a@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 11/12/2014 20:31, Thomas Petazzoni a =E9crit :
> Dear Cyrille Pitchen,
>=20
> On Thu, 11 Dec 2014 11:16:51 +0100, Cyrille Pitchen wrote:
>=20
>> +#define GEM_ISR1				0x0400
>> +#define GEM_ISR2				0x0404
>> +#define GEM_ISR3				0x0408
>> +#define GEM_ISR4				0x040c
>> +#define GEM_ISR5				0x0410
>> +#define GEM_ISR6				0x0414
>> +#define GEM_ISR7				0x0418
>=20
> What about doing instead:
>=20
> #define GEM_ISR(q)				((q) =3D=3D 0 ? MACB_ISR : 0x400 + (q) << 2)
>=20
> And ditto for all other registers, which will save a lot of boring re=
peated code.
>=20
> If you do that, then you can avoid the following fields in the
> macb_queue structure:
>=20
> +	unsigned int		ISR;
> +	unsigned int		IER;
> +	unsigned int		IDR;
> +	unsigned int		IMR;
> +	unsigned int		TBQP;
>=20
> And the not very pleasant calculation of those offsets:
>=20
> +	bp->queues[0].bp =3D bp;
> +	bp->queues[0].ISR  =3D MACB_ISR;
> +	bp->queues[0].IER  =3D MACB_IER;
> +	bp->queues[0].IDR  =3D MACB_IDR;
> +	bp->queues[0].IMR  =3D MACB_IMR;
> +	bp->queues[0].TBQP =3D MACB_TBQP;
> +	for (q =3D 1, queue =3D &bp->queues[1]; q < MACB_MAX_QUEUES; ++q) {
> +		if (!(queue_mask & (1 << q)))
> +			continue;
> +
> +		queue->bp =3D bp;
> +		queue->ISR  =3D (q-1) * sizeof(u32) + GEM_ISR1;
> +		queue->IER  =3D (q-1) * sizeof(u32) + GEM_IER1;
> +		queue->IDR  =3D (q-1) * sizeof(u32) + GEM_IDR1;
> +		queue->IMR  =3D (q-1) * sizeof(u32) + GEM_IMR1;
> +		queue->TBQP =3D (q-1) * sizeof(u32) + GEM_TBQP1;
> +		queue++;
> +	}
>=20
> You replace the ISR, IER, IDR, IMR and TBQP by an "id" field in
> macb_queue, which contains the queue number, and then change your:
>=20
> +#define queue_readl(queue, reg)				\
> +	__raw_readl((queue)->bp->regs + queue->reg)
> +#define queue_writel(queue, reg, value)			\
> +	__raw_writel((value), (queue)->bp->regs + queue->reg)
>=20
> to
>=20
> +#define queue_readl(queue, reg)				\
> +	__raw_readl((queue)->bp->regs + reg((queue)->id))
> +#define queue_writel(queue, reg, value)			\
> +	__raw_writel((value), (queue)->bp->regs + reg((queue)->id)
>=20
> Best regards,
>=20
> Thomas
>=20
Good idea, I'm working on it.

Thanks,

Cyrille
