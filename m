From: Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH v2 07/46] net/wireless: ath9k: fix DMA API usage
Date: Wed, 13 Jul 2011 00:04:50 +0800
Message-ID: <57124BD4-F53A-4424-A61F-5D8E629EB36F@nbd.name>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl> <280ad9176e6532f231e054b38b952b20580874c5.1310339688.git.mirq-linux@rere.qmqm.pl> <4E1BCF36.2010506@openwrt.org> <20110712095541.GA6236@rere.qmqm.pl> <B4765EFC-B5C9-4E2D-BE00-ED5519D13A4E@nbd.name> <20110712130316.GA8621@rere.qmqm.pl> <EC2F82D7-9206-4139-9539-F5DDE38A5629@nbd.name> <20110712155849.GB10651@rere.qmqm.pl>
Mime-Version: 1.0 (iPhone Mail 8H7)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	"ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org" <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
	"linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org" <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
To: =?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110712155849.GB10651-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12.07.2011, at 23:58, Micha=C5=82 Miros=C5=82aw <mirq-linux-CoA6ZxLDdyE@public.gmane.org=
m.pl> wrote:

> On Tue, Jul 12, 2011 at 10:21:05PM +0800, Felix Fietkau wrote:
>> On 12.07.2011, at 21:03, Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.=
qmqm.pl> wrote:
>>=20
>>> On Tue, Jul 12, 2011 at 08:54:32PM +0800, Felix Fietkau wrote:
>>>> On 12.07.2011, at 17:55, Micha=C5=82 Miros=C5=82aw <mirq-linux@rer=
e.qmqm.pl> wrote:
>>>>=20
>>>>> On Tue, Jul 12, 2011 at 12:36:06PM +0800, Felix Fietkau wrote:
>>>>>> On 2011-07-11 8:52 AM, Micha=C5=82 Miros=C5=82aw wrote:
>>>>>>> Also constify buf_addr for ath9k_hw_process_rxdesc_edma() to ve=
rify
>>>>>>> assumptions --- dma_sync_single_for_device() call can be remove=
d.
>>>>>>>=20
>>>>>>> Signed-off-by: Micha=C5=82 Miros=C5=82aw<mirq-linux-CoA6ZxLDdyHykr9aO5hl4Q@public.gmane.org=
l>
>>>>>>> ---
>>>>>>> drivers/net/wireless/ath/ath9k/ar9003_mac.c |    4 ++--
>>>>>>> drivers/net/wireless/ath/ath9k/ar9003_mac.h |    2 +-
>>>>>>> drivers/net/wireless/ath/ath9k/recv.c       |   10 +++-------
>>>>>>> 3 files changed, 6 insertions(+), 10 deletions(-)
>>>>>>>=20
>>>>>>> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/ne=
t/wireless/ath/ath9k/recv.c
>>>>>>> index 70dc8ec..c5f46d5 100644
>>>>>>> --- a/drivers/net/wireless/ath/ath9k/recv.c
>>>>>>> +++ b/drivers/net/wireless/ath/ath9k/recv.c
>>>>>>> @@ -684,15 +684,11 @@ static bool ath_edma_get_buffers(struct a=
th_softc *sc,
>>>>>>>  BUG_ON(!bf);
>>>>>>>=20
>>>>>>>  dma_sync_single_for_cpu(sc->dev, bf->bf_buf_addr,
>>>>>>> -                common->rx_bufsize, DMA_FROM_DEVICE);
>>>>>>> +                common->rx_bufsize, DMA_BIDIRECTIONAL);
>>>>>>>=20
>>>>>>>  ret =3D ath9k_hw_process_rxdesc_edma(ah, NULL, skb->data);
>>>>>>> -    if (ret =3D=3D -EINPROGRESS) {
>>>>>>> -        /*let device gain the buffer again*/
>>>>>>> -        dma_sync_single_for_device(sc->dev, bf->bf_buf_addr,
>>>>>>> -                common->rx_bufsize, DMA_FROM_DEVICE);
>>>>>>> +    if (ret =3D=3D -EINPROGRESS)
>>>>>>>      return false;
>>>>>>> -    }
>>>>>>>=20
>>>>>>>  __skb_unlink(skb,&rx_edma->rx_fifo);
>>>>>>>  if (ret =3D=3D -EINVAL) {
>>>>>> I have strong doubts about this change. On most MIPS devices,
>>>>>> dma_sync_single_for_cpu is a no-op, whereas
>>>>>> dma_sync_single_for_device flushes the cache range. With this
>>>>>> change, the CPU could cache the DMA status part behind skb->data=
 and
>>>>>> that cache entry would not be flushed inbetween calls to this
>>>>>> functions on the same buffer, likely leading to rx stalls.
>>>>> You're suggesting a platform implementation bug then. If the plat=
form is not
>>>>> cache-coherent, it should invalidate relevant CPU cache lines for=
 sync_to_cpu
>>>>> and unmap cases. Do other devices show such symptoms on MIPS syst=
ems?
>>>>>=20
>>>>> I'm not familiar with the platform internals, so we should ask MI=
PS people.
>>>> I only mentioned MIPS to describe the potential side effect of thi=
s change. From my current understanding of the DMA API, it would be wro=
ng on other platforms as well. I believe the _for_device function needs=
 to be used to transfer ownership of the buffer back to the device, bef=
ore calling _for_cpu again later for another read.
>>> What you're saying reminds the wording in DMA-API-HOWTO.txt that I =
find
>>> wrong (or at least misleading) compared to what DMA-API.txt describ=
es.
>>> DMA sync calls do not transfer the ownership of the buffer - they a=
re
>>> cache synchronization points, ownership passing is handled entirely=
 by
>>> the driver.
>> What I meant was that the DMA sync calls reflect the ownership trans=
fer of the memory regions. In this case ownership is transferred betwee=
n device and CPU multiple times and the code reflects that.
>>>> This is definitely required in this case, because when the return =
code is -EINPROGRESS, the driver waits for the hardware to complete thi=
s buffer, and the next call has to fetch the memory again after the dev=
ice has updated it.
>>> Correctness of this access should be provided by sync_to_cpu() call=
=2E
>> At least in MIPS I'm sure it isn't. If I remember correctly, it also=
 isn't on ARM, so I'm pretty sure that either your understanding of the=
 API is incorrect, or arch code does not implement it properly. In eith=
er case, this change (and probably also the p54 one) should not be merg=
ed.
>=20
> I briefly looked through DMA API implementation in MIPS, and except
> for R10k and R12k both sync_for_cpu and sync_for_device are no-ops
> (see: arch/mips/mm/dma-default.c).  For R10k and R12k the syncs are
> in both points, and exactly like I described before - CPU cachelines
> are invalidated for DMA_FROM_DEVICE mappings, written back for
> DMA_TO_DEVICE, both for DMA_BIDIRECTIONAL (including redundant
> mapping+sync direction).
>=20
> So doing that sync_to_device you are just invalidating the same cache=
lines
> twice for no gain (or do nothing twice in some cases) - they are not =
read
> by CPU between sync_to_device -> sync_to_cpu (unless you have other b=
ugs
> in the driver).=20
I think you're missing something. It works like this: In the AR9380 rx =
path, the descriptor is part of the skb. The rx tasklet checks for rx f=
rame completion by calling the sync for cpu, reading the completion fla=
g and (in case of a not completed frame) flushes the cache for that loc=
ation again (for device). If you remove the for_device call, the next c=
all to this function can see stale data, as the for_cpu call can be a n=
o-op.

- Felix--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
