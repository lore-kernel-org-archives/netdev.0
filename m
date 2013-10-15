From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH RFC 4/5] net: macb: Use devm_request_irq()
Date: Tue, 15 Oct 2013 13:20:16 -0700
Message-ID: <ffb65abe-36e2-45c3-9d40-02050545184d@TX2EHSMHS038.ehs.local>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com>
 <1381795140-10792-5-git-send-email-soren.brinkmann@xilinx.com>
 <525D95A4.3020706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <525D95A4.3020706@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2013 at 11:21:08PM +0400, Sergei Shtylyov wrote:
> Hello.
>=20
> On 10/15/2013 03:58 AM, Soren Brinkmann wrote:
>=20
> >Use the device managed interface to request the IRQ, simplifying err=
or
> >paths.
>=20
> >Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
> >---
> >  drivers/net/ethernet/cadence/macb.c | 8 +++-----
> >  1 file changed, 3 insertions(+), 5 deletions(-)
>=20
> >diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
> >index 436aecc31732..603844b1d483 100644
> >--- a/drivers/net/ethernet/cadence/macb.c
> >+++ b/drivers/net/ethernet/cadence/macb.c
> >@@ -1825,7 +1825,8 @@ static int __init macb_probe(struct platform_d=
evice *pdev)
> >  	}
> >
> >  	dev->irq =3D platform_get_irq(pdev, 0);
> >-	err =3D request_irq(dev->irq, macb_interrupt, 0, dev->name, dev);
> >+	err =3D devm_request_irq(&pdev->dev, dev->irq, macb_interrupt, 0,
> >+			dev->name, dev);
>=20
>    You should start the continuation line right under &.
Actually this one is a good example why I don't do such alignment: You
do a simple search & replace - in this case request_irq ->
devm_request_irq - and all alignment is gone.

	S=C3=B6ren
