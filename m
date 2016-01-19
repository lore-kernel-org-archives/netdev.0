From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [GIT] Networking
Date: Tue, 19 Jan 2016 10:36:07 +0100
Message-ID: <569E0387.1070601@broadcom.com>
References: <20160112.215136.850414372508130298.davem@davemloft.net>
 <56978094.4050302@arm.com> <87k2n97n5e.fsf@kamboji.qca.qualcomm.com>
 <569CCCD2.4040105@arm.com> <569D61BA.8020701@broadcom.com>
 <569DFA0A.6070900@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-wireless@vger.kernel.org>
To: Marc Zyngier <marc.zyngier@arm.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Hante Meuleman <meuleman@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:3980 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757703AbcASJgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 04:36:11 -0500
In-Reply-To: <569DFA0A.6070900@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19-1-2016 9:55, Marc Zyngier wrote:
> On 18/01/16 22:05, Arend van Spriel wrote:
>> On 18-1-2016 12:30, Marc Zyngier wrote:
>>> Hi Kalle,
>>>
>>> On 16/01/16 11:57, Kalle Valo wrote:
>>>> Marc Zyngier <marc.zyngier@arm.com> writes:
>>>>
>>>>> David, Hante,
>>>>>
>>>>> On 13/01/16 02:51, David Miller wrote:
>>>>>
>>>>> [...]
>>>>>
>>>>>> Hante Meuleman (33):
>>>>> [...]
>>>>>>       brcmfmac: Move all module parameters to one place
>>>>
>>>> As a reminder to myself this is the commit id:
>>>>
>>>> 7d34b0560567 brcmfmac: Move all module parameters to one place
>>>>
>>>>> This particular patch breaks one of my boxes in a spectacular way:
>>>>>
>>>>> [    3.602155] Unable to handle kernel paging request at virtual address 000027e4
>>>>> [    3.602160] pgd = c0003000
>>>>> [    3.602169] [000027e4] *pgd=80000040004003, *pmd=00000000
>>>>> [    3.602181] Internal error: Oops: 206 [#1] PREEMPT SMP ARM
>>>>
>>>> [...]
>>>>
>>>>> This is caused by this hunk:
>>>>>
>>>>> @@ -890,7 +887,8 @@ static void brcmf_sdiod_sgtable_alloc(struct brcmf_sdio_dev *sdiodev)
>>>>>  	if (!sdiodev->sg_support)
>>>>>  		return;
>>>>>  
>>>>> -	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE, brcmf_sdiod_txglomsz);
>>>>> +	nents = max_t(uint, BRCMF_DEFAULT_RXGLOM_SIZE,
>>>>> +		      sdiodev->bus_if->drvr->settings->sdiod_txglomsz);
>>>>>  	nents += (nents >> 4) + 1;
>>>>>  
>>>>>  	WARN_ON(nents > sdiodev->max_segment_count);
>>>>>
>>>>> were drvr->settings is NULL (as the settings allocation seems to be done
>>>>> much later). The fix is not completely obvious to me (probably requires
>>>>> pushing the call to brcmf_mp_device_attach() down into the various bus
>>>>> specific functions). An alternative would be to restore the txglomsz
>>>>> parameter as it was before and not rely on settings being allocated.
>>>>
>>>> Should we revert the patch or can you Hante fix this? The revert doesn't
>>>> seem to be trivial so I would appreciate if someone could send a patch.
>>>
>>> I've worked out a partial revert (see below) that allows my system to
>>> boot, but I'd rather see a proper fix from the maintainer of this code.
>>
>> Hi Marc,
>>
>> Thanks for the patch, but Hante has created a different patch basically
>> deferring the allocation of the sgtable. Feel free to give it a spin on
>> your box and share the results.
> 
> Hi Arend,
> 
> This patch fixes indeed the problem, thanks (I had to undo the mangling
> your mailer had done, though). So feel free to add my:

Thanks, Marc

I started using thunderbird on windows 7. Probably better revert to the
one on Citrix.

> Reported-by: Marc Zyngier <marc.zyngier@arm.com>
> Tested-by: Marc Zyngier <marc.zyngier@arm.com>
> 
> It would be good if this could make it in -rc1.

Will try to submit a clean patch to Kalle.

>> I am looking for a arm64 platform to add to my test machines so if
>> you can recommend one (with PCIe).
> 
> Note that this crash happened with 32bit ARM, without PCIe (the box is a
> "Cubietruck").
> 
> As for arm64, there is now quite a few machines out there (ARM sells a
> dev board called Juno, but there is also various offerings with AMD
> Opteron A1100, Cavium ThunderX, APM X-Gene, and maybe even some Broadcom
> based systems, who knows! ;-).

Thanks. Actually found something in our corporate spam:

http://www.broadcom.com/press/release.php?id=s948493

Regards,
Arend

> Thanks,
> 
> 	M.
> 
