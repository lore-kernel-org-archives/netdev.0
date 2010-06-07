From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2] net: ll_temac: fix interrupt bug when interrupt 0 is
	used
Date: Sun, 6 Jun 2010 18:47:59 -0600
Message-ID: <AANLkTilqN1coce-O9FKF7_xo_k_xsVN6zT1GyXF7I30m@mail.gmail.com>
References: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
	<1275861445.1931.2974.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Brian Hill <brian.hill@xilinx.com>, michal.simek@petalogix.com,
	John Linn <john.linn@xilinx.com>, john.williams@petalogix.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1275861445.1931.2974.camel@pasglop>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 6, 2010 at 3:57 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Wed, 2010-05-26 at 11:29 -0600, John Linn wrote:
>> The code is not checking the interrupt for DMA correctly so that an
>> interrupt number of 0 will cause a false error.
>>
>> Signed-off-by: Brian Hill <brian.hill@xilinx.com>
>> Signed-off-by: John Linn <john.linn@xilinx.com>
>> ---
>> =A0drivers/net/ll_temac_main.c | =A0 =A02 +-
>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
>> index fa7620e..0615737 100644
>> --- a/drivers/net/ll_temac_main.c
>> +++ b/drivers/net/ll_temac_main.c
>> @@ -950,7 +950,7 @@ temac_of_probe(struct of_device *op, const struct of=
_device_id *match)
>>
>> =A0 =A0 =A0 lp->rx_irq =3D irq_of_parse_and_map(np, 0);
>> =A0 =A0 =A0 lp->tx_irq =3D irq_of_parse_and_map(np, 1);
>> - =A0 =A0 if (!lp->rx_irq || !lp->tx_irq) {
>> + =A0 =A0 if ((lp->rx_irq =3D=3D NO_IRQ) || (lp->tx_irq =3D=3D NO_IRQ)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&op->dev, "could not determine irqs\=
n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D -ENOMEM;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nodev;
>
> Hasn't NO_IRQ been deprecated ?

ARM still uses it, plus less than a handful of other arches.  There is
no reason for Microblaze to use NO_IRQ as -1.

In fact, on ARM, as part of the device tree work I'm hoping to piggy
back in irq remapping and make 0 no longer a valid irq.

> Linus made it clear a while back that interrupt 0 was not valid and
> that's the way it should be.
>
> We now have an interrupt remapping scheme on powerpc, so we ensure that
> 0 always mean no interrupt. Other archs might need some fixups. Which
> are specifically needs this patch ?

Microblaze.

BTW jlinn, for xilinx ARM support we should make sure 0 is never used
as a valid IRQ from day one.  It will result it far less pain in the
future.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
