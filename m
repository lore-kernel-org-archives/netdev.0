From: <Andrei.Pistirica@microchip.com>
Subject: RE: [PATCH net-next] macb: Common code to enable ptp support for
 SAMA5Dx platforms.
Date: Thu, 19 Jan 2017 10:21:08 +0000
Message-ID: <07C910AB6AC6C345A093D5A08F5AF568CB786983@CHN-SV-EXMX03.mchp-main.com>
References: <1484758673-8694-1-git-send-email-andrei.pistirica@microchip.com>
 <1c534b5a-25cb-a5d6-f87c-db9ed958a606@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: boris.brezillon@free-electrons.com, alexandre.belloni@free-electrons.com,
 michals@xilinx.com, tbultel@pixelsurmer.com, anirudh@xilinx.com,
 punnaia@xilinx.com
To: <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
 <davem@davemloft.net>, <harinikatakamlinux@gmail.com>,
 <harini.katakam@xilinx.com>, <richardcochran@gmail.com>, <rafalo@cadence.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1c534b5a-25cb-a5d6-f87c-db9ed958a606@atmel.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> Subject: Re: [PATCH net-next] macb: Common code to enable ptp support
> for SAMA5Dx platforms.
> =

> Le 18/01/2017 =E0 09:57, Andrei Pistirica a =E9crit :
> > This patch does the following:
> > - add GEM-PTP interface
> > - registers and bitfields for TSU are named according to SAMA5Dx data
> > sheet
> > - PTP support based on platform capability
> =

> The $subject will certainly never match reality, sadly "enable ptp support
> for SAMA5Dx platforms". So, you'd better change it.
> (no "." at the end BTW).

I will change it to: " Common code to enable ptp support for MACB/GEM"

> > +2518,7 @@ static void macb_configure_caps(struct macb *bp,
> >  		dcfg =3D gem_readl(bp, DCFG2);
> >  		if ((dcfg & (GEM_BIT(RX_PKT_BUFF) |
> GEM_BIT(TX_PKT_BUFF))) =3D=3D 0)
> >  			bp->caps |=3D MACB_CAPS_FIFO_MODE;
> > +
> =

> Nitpicking, just because other issue exists: this white line doesn't belo=
ng to
> the patch.

Ok I'll remove it. I missed it because checkpatch didn't report any warning.

[...]

> >  #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
> >  #define MACB_CAPS_SG_DISABLED			0x40000000
> >  #define MACB_CAPS_MACB_IS_GEM			0x80000000
> > +#define MACB_CAPS_GEM_HAS_PTP			0x00000020
> =

> No, this mask already exists a couple of lines above:
> #define MACB_CAPS_JUMBO        0x00000020
> =

> That leads to a NACK, sorry (I didn't spotted earlier, BTW).

Yes... you are right... sorry.

[...] =


> Otherwise, I'm okay with the rest.
> =

> I suggest to people that will keep the ball rolling on this topic to take
> advantage of the chunks of code that Andrei developed with the help of
> Richard and the best practices discussed. I think particularly, if it mak=
es
> sense with HW, about:
> - gem_ptp_do_[rt]xstamp(bp, skb) dereference scheme
> - gem_ptp_adjfine() rationale
> - gem_get_ptp_peer() if needed

Just mind that in case of an implementation with buffer rings and irqs
a different mechanism have to be used.

Regards,
Andrei

> =

> Regards,
> --
> Nicolas Ferre
