From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH v2] r8169: set coherent DMA mask as well as streaming DMA mask
Date: Fri, 14 Oct 2016 14:46:53 +0100
Message-ID: <6D7D95BB-DE3E-48E0-ACDA-8E1C58875F79@linaro.org>
References: <1476452433-20518-1-git-send-email-ard.biesheuvel@linaro.org> <063D6719AE5E284EB5DD2968C1650D6DB01FF652@AcuExch.aculab.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: "romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
        "nic_swsd@realtek.com" <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:33631 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756692AbcJNNq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 09:46:59 -0400
Received: by mail-qt0-f175.google.com with SMTP id s49so74729701qta.0
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 06:46:59 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB01FF652@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 14 Oct 2016, at 14:42, David Laight<David.Laight@ACULAB.COM> wrote:
>=20
> From: Of Ard Biesheuvel
>> Sent: 14 October 2016 14:41
>> PCI devices that are 64-bit DMA capable should set the coherent
>> DMA mask as well as the streaming DMA mask. On some architectures,
>> these are managed separately, and so the coherent DMA mask will be
>> left at its default value of 32 if it is not set explicitly. This
>> results in errors such as
>>=20
>>     r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>>     hwdev DMA mask =3D 0x00000000ffffffff, dev_addr =3D 0x00000080fbfff00=
0
>>     swiotlb: coherent allocation failed for device 0000:02:00.0 size=3D40=
96
>>     CPU: 0 PID: 1062 Comm: systemd-udevd Not tainted 4.8.0+ #35
>>     Hardware name: AMD Seattle/Seattle, BIOS 10:53:24 Oct 13 2016
>>=20
>> on systems without memory that is 32-bit addressable by PCI devices.
>>=20
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>> v2: dropped the hunk that sets the coherent DMA mask to DMA_BIT_MASK(32),=

>>    which is unnecessary given that it is the default
>>=20
>> drivers/net/ethernet/realtek/r8169.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/=
realtek/r8169.c
>> index e55638c7505a..bf000d819a21 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -8273,7 +8273,8 @@ static int rtl_init_one(struct pci_dev *pdev, const=
 struct pci_device_id *ent)
>>    if ((sizeof(dma_addr_t) > 4) &&
>>        (use_dac =3D=3D 1 || (use_dac =3D=3D -1 && pci_is_pcie(pdev) &&
>>                  tp->mac_version >=3D RTL_GIGA_MAC_VER_18)) &&
>> -        !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
>> +        !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
>> +        !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
>=20
> Isn't there a dma_set_mask_and_coherent() function ?
>=20
>    David
>=20
