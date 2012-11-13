From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] tilegx: request_irq with a non-null device name
Date: Tue, 13 Nov 2012 16:59:41 -0500
Message-ID: <50A2C2CD.9090308@tilera.com>
References: <1352840300-27814-1-git-send-email-simon.marchi@polymtl.ca> <50A2BD87.3060202@tilera.com> <CAFXXi0kcGCqr-Ss5-Li9vXKCWyTh6Nvx+aAzVUZ1PZbZ=YZ2Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Simon Marchi <simon.marchi@polymtl.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFXXi0kcGCqr-Ss5-Li9vXKCWyTh6Nvx+aAzVUZ1PZbZ=YZ2Pg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2012 4:54 PM, Simon Marchi wrote:
> On Tue, Nov 13, 2012 at 1:37 PM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>> On 11/13/2012 3:58 PM, Simon Marchi wrote:
>>> This patch simply makes the tilegx net driver call request_irq with a
>>> non-null name. It makes the output in /proc/interrupts more obvious, but
>>> also helps tools that don't expect to find null there.
>>>
>>> Signed-off-by: Simon Marchi <simon.marchi@polymtl.ca>
>>> ---
>>>  drivers/net/ethernet/tile/tilegx.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
>>> index 4e98100..66e025a 100644
>>> --- a/drivers/net/ethernet/tile/tilegx.c
>>> +++ b/drivers/net/ethernet/tile/tilegx.c
>>> @@ -917,7 +917,7 @@ static int tile_net_setup_interrupts(struct net_device *dev)
>>>       ingress_irq = rc;
>>>       tile_irq_activate(ingress_irq, TILE_IRQ_PERCPU);
>>>       rc = request_irq(ingress_irq, tile_net_handle_ingress_irq,
>>> -                      0, NULL, NULL);
>>> +                      0, "tile_net", NULL);
>> Good catch.  If you can change it to dev->name instead of "tile_net", feel
>> free to add my:
> I thought about that first, but it wouldn't be very logical. This
> module is loaded once and for all when the first network device is
> brought up, so this request_irq is for all the tile network
> interfaces. Suppose you "up" gbe0, "up" gbe1 and "down" gbe0, the
> device name would still be gbe0, even though it's down. That's why I
> opted for a generic name instead.
>
> If you still want to go with dev->name I have no problem with that.

No, you're right, that's a good point.  It does probably make more sense to
use "tile_net".  So apply my Acked-by to your patch as-is.  Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
