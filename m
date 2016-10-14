From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] r8169: set coherent DMA mask as well as streaming DMA mask
Date: Fri, 14 Oct 2016 14:36:23 +0100
Message-ID: <CAKv+Gu96R1pmsbCRFzDK3=LP05dYb-849qRNn83-JWVexDupzg@mail.gmail.com>
References: <1476445170-4496-1-git-send-email-ard.biesheuvel@linaro.org>
 <20161014.093101.1348173909013700977.davem@davemloft.net> <CAKv+Gu_HEANqHNh5d_b=-3djA__8MkE7UE5ps8rTFuCuJURcVQ@mail.gmail.com>
 <20161014.093403.1591217631213879011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Realtek linux nic maintainers <nic_swsd@realtek.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161014.093403.1591217631213879011.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14 October 2016 at 14:34, David Miller <davem@davemloft.net> wrote:
> From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Date: Fri, 14 Oct 2016 14:32:24 +0100
>
>> On 14 October 2016 at 14:31, David Miller <davem@davemloft.net> wrote:
>>> From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>>> Date: Fri, 14 Oct 2016 12:39:30 +0100
>>>
>>>> PCI devices that are 64-bit DMA capable should set the coherent
>>>> DMA mask as well as the streaming DMA mask. On some architectures,
>>>> these are managed separately, and so the coherent DMA mask will be
>>>> left at its default value of 32 if it is not set explicitly. This
>>>> results in errors such as
>>>>
>>>>      r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>>>>      hwdev DMA mask = 0x00000000ffffffff, dev_addr = 0x00000080fbfff000
>>>>      swiotlb: coherent allocation failed for device 0000:02:00.0 size=4096
>>>>      CPU: 0 PID: 1062 Comm: systemd-udevd Not tainted 4.8.0+ #35
>>>>      Hardware name: AMD Seattle/Seattle, BIOS 10:53:24 Oct 13 2016
>>>>
>>>> on systems without memory that is 32-bit addressable by PCI devices.
>>>>
>>>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>>>  ...
>>>> @@ -8281,6 +8282,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>>>>               dev->features |= NETIF_F_HIGHDMA;
>>>>       } else {
>>>>               rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
>>>> +             if (!rc)
>>>> +                     rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
>>>
>>> As you state 32-bit is the default, therefore this part of your patch is unnecessary.
>>
>> Perhaps, but the original code did not assume that either. Should I
>> remove the other call in a subsequent patch as well?
>
> I simply want you to respin this with the above hunk removed.
>
> Your code changes and your commit message must be consistent.

OK, fair enough
