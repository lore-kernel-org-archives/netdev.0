From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [GIT] Networking
Date: Sat, 16 Jan 2016 13:57:01 +0200
Message-ID: <87k2n97n5e.fsf@kamboji.qca.qualcomm.com>
References: <20160112.215136.850414372508130298.davem@davemloft.net>
	<56978094.4050302@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56978094.4050302-5wv7dgnIgG8@public.gmane.org> (Marc Zyngier's message of "Thu, 14
	Jan 2016 11:03:48 +0000")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org> writes:

> David, Hante,
>
> On 13/01/16 02:51, David Miller wrote:
>
> [...]
>
>> Hante Meuleman (33):
> [...]
>>       brcmfmac: Move all module parameters to one place

As a reminder to myself this is the commit id:

7d34b0560567 brcmfmac: Move all module parameters to one place

> This particular patch breaks one of my boxes in a spectacular way:
>
> [    3.602155] Unable to handle kernel paging request at virtual address 000027e4
> [    3.602160] pgd = c0003000
> [    3.602169] [000027e4] *pgd=80000040004003, *pmd=00000000
> [    3.602181] Internal error: Oops: 206 [#1] PREEMPT SMP ARM

[...]

> This is caused by this hunk:
>
> @@ -890,7 +887,8 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
>  	if (!sdiodev->sg_support)
>  		return;
>  
> -	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE, brcmf_sdiod_txglomsz);
> +	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE,
> +		      sdiodev->bus_if->drvr->settings->sdiod_txglomsz);
>  	nents += (nents >> 4) + 1;
>  
>  	WARN_ON(nents > sdiodev->max_segment_count);
>
> were drvr->settings is NULL (as the settings allocation seems to be done
> much later). The fix is not completely obvious to me (probably requires
> pushing the call to brcmf_mp_device_attach() down into the various bus
> specific functions). An alternative would be to restore the txglomsz
> parameter as it was before and not rely on settings being allocated.

Should we revert the patch or can you Hante fix this? The revert doesn't
seem to be trivial so I would appreciate if someone could send a patch.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
