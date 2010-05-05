From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/gianfar: drop recycled skbs on MTU change
Date: Wed, 05 May 2010 00:57:04 -0700 (PDT)
Message-ID: <20100505.005704.115933493.davem@davemloft.net>
References: <20100503151745.GA17997@Chamillionaire.breakpoint.cc>
	<o2g2acbd3e41005040829rc5bf7e0dwee8419b2b65e5468@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian@breakpoint.cc, afleming@freescale.com,
	netdev@vger.kernel.org
To: afleming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757898Ab0EEH45 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 03:56:57 -0400
In-Reply-To: <o2g2acbd3e41005040829rc5bf7e0dwee8419b2b65e5468@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andy Fleming <afleming@gmail.com>
Date: Tue, 4 May 2010 08:29:06 -0700

> On Mon, May 3, 2010 at 8:17 AM, Sebastian Andrzej Siewior
> <sebastian@breakpoint.cc> wrote:
>> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>>
>> The size for skb which is added to the recycled list is using the
>> current descriptor size which is current MTU. gfar_new_skb() is also
>> using this size. So after changing or alteast increasing the MTU all
>> recycled skbs should be dropped.
>>
>> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>> ---
>> I'm not 100% sure but it looks like it is wrong.
>>
>> =A0drivers/net/gianfar.c | =A0 =A04 +++-
>> =A01 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
>> index 5267c27..9093106 100644
>> --- a/drivers/net/gianfar.c
>> +++ b/drivers/net/gianfar.c
>> @@ -2287,8 +2287,10 @@ static int gfar_change_mtu(struct net_device =
*dev, int new_mtu)
>>
>> =A0 =A0 =A0 =A0/* Only stop and start the controller if it isn't alr=
eady
>> =A0 =A0 =A0 =A0 * stopped, and we changed something */
>> - =A0 =A0 =A0 if ((oldsize !=3D tempsize) && (dev->flags & IFF_UP))
>> + =A0 =A0 =A0 if ((oldsize !=3D tempsize) && (dev->flags & IFF_UP)) =
{
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stop_gfar(dev);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_purge(&priv->rx_recycle);
>> + =A0 =A0 =A0 }
>=20
>=20
> I think we should probably do this in free_skb_resources.  And remove
> the call from gfar_close().

Ok, Sebastian please rework your patch as requested by Andy.

Thanks.
