From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2] net: ll_temac: fix interrupt bug when interrupt 0 is
	used
Date: Sat, 5 Jun 2010 21:33:06 -0600
Message-ID: <AANLkTilkPhfqRqu8vnYEbGZbYAyw2fmWhK050zAOKkZu@mail.gmail.com>
References: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
	<AANLkTin0Lg8HCpCAmyy_ybPlv6K9_iyE2aFrhifw486D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Brian Hill <brian.hill@xilinx.com>, michal.simek@petalogix.com,
	John Linn <john.linn@xilinx.com>
To: John Williams <john.williams@petalogix.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <AANLkTin0Lg8HCpCAmyy_ybPlv6K9_iyE2aFrhifw486D@mail.gmail.com>
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

On Wed, May 26, 2010 at 10:12 PM, John Williams
<john.williams@petalogix.com> wrote:
> On Thu, May 27, 2010 at 3:29 AM, John Linn <john.linn@xilinx.com> wrote:
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
>> =A0 =A0 =A0 =A0lp->rx_irq =3D irq_of_parse_and_map(np, 0);
>> =A0 =A0 =A0 =A0lp->tx_irq =3D irq_of_parse_and_map(np, 1);
>> - =A0 =A0 =A0 if (!lp->rx_irq || !lp->tx_irq) {
>> + =A0 =A0 =A0 if ((lp->rx_irq =3D=3D NO_IRQ) || (lp->tx_irq =3D=3D NO_IR=
Q)) {
>
> Personally I think this is the right thing to do. =A0But, I thought the
> IRQ 0 =3D=3D NO_IRQ (AKA "all-the-world's-an-x86-and-if-not-it-should-be")
> holy war was already fought and won (or lost, depending on your
> perspective)?
>
> I seem to recall giving reluctant assent to a patch from Grant a few
> months ago that touched MicroBlaze thus?

I've still got the patch in my private queue.  I can reapply it, test
it and repost it.  I think what was still a bit up in the air was the
exact method to map hw irq numbers onto linux irqs.

g.
