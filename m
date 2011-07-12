From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH v2 07/46] net/wireless: ath9k: fix DMA API
 usage
Date: Mon, 11 Jul 2011 22:30:23 -0700
Message-ID: <4E1BDBEF.1090505@candelatech.com>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl> <280ad9176e6532f231e054b38b952b20580874c5.1310339688.git.mirq-linux@rere.qmqm.pl> <4E1BCF36.2010506@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E1BCF36.2010506-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/11/2011 09:36 PM, Felix Fietkau wrote:
> On 2011-07-11 8:52 AM, Micha=C5=82 Miros=C5=82aw wrote:
>> Also constify buf_addr for ath9k_hw_process_rxdesc_edma() to verify
>> assumptions --- dma_sync_single_for_device() call can be removed.
>>
>> Signed-off-by: Micha=C5=82 Miros=C5=82aw<mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
>> ---
>> drivers/net/wireless/ath/ath9k/ar9003_mac.c | 4 ++--
>> drivers/net/wireless/ath/ath9k/ar9003_mac.h | 2 +-
>> drivers/net/wireless/ath/ath9k/recv.c | 10 +++-------
>> 3 files changed, 6 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wir=
eless/ath/ath9k/recv.c
>> index 70dc8ec..c5f46d5 100644
>> --- a/drivers/net/wireless/ath/ath9k/recv.c
>> +++ b/drivers/net/wireless/ath/ath9k/recv.c
>> @@ -684,15 +684,11 @@ static bool ath_edma_get_buffers(struct ath_so=
ftc *sc,
>> BUG_ON(!bf);
>>
>> dma_sync_single_for_cpu(sc->dev, bf->bf_buf_addr,
>> - common->rx_bufsize, DMA_FROM_DEVICE);
>> + common->rx_bufsize, DMA_BIDIRECTIONAL);
>>
>> ret =3D ath9k_hw_process_rxdesc_edma(ah, NULL, skb->data);
>> - if (ret =3D=3D -EINPROGRESS) {
>> - /*let device gain the buffer again*/
>> - dma_sync_single_for_device(sc->dev, bf->bf_buf_addr,
>> - common->rx_bufsize, DMA_FROM_DEVICE);
>> + if (ret =3D=3D -EINPROGRESS)
>> return false;
>> - }
>>
>> __skb_unlink(skb,&rx_edma->rx_fifo);
>> if (ret =3D=3D -EINVAL) {
> I have strong doubts about this change. On most MIPS devices, dma_syn=
c_single_for_cpu is a no-op, whereas dma_sync_single_for_device flushes=
 the cache range.
> With this change, the CPU could cache the DMA status part behind skb-=
>data and that cache entry would not be flushed inbetween calls to this=
 functions on the
> same buffer, likely leading to rx stalls.

At the very least, it would need heavy testing.  It took a very long ti=
me to get
the ath9k DMA issues (mostly?) resolved...so we shouldn't go mucking in=
 this
code on theory...

Thanks,
Ben

>
> - Felix
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
