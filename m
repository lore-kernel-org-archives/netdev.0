From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Fri, 18 Nov 2016 15:28:36 +0530
Message-ID: <CAFcVECK=tUrfz=ejKHLimVU3uX7GgBNLrObjSP=87RmV4CSLkw@mail.gmail.com>
References: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
 <e6773b4e-a633-4754-893d-fd2351d07459@atmel.com> <BN3PR07MB2516EBCDD8822FC5F8A9095FC9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVEC+RqUMQF39oe2EuCoisX6dCwRQ3G81zFMqoOHU3HpfPHQ@mail.gmail.com> <BN3PR07MB25166D8301C60C4A35402AB1C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36199 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752723AbcKRKKs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 05:10:48 -0500
In-Reply-To: <BN3PR07MB25166D8301C60C4A35402AB1C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rafal,

On Fri, Nov 18, 2016 at 2:29 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
> Hello,
>
>> From: Harini Katakam [mailto:harinikatakamlinux@gmail.com]
>> Sent: 18 listopada 2016 05:30
>> To: Rafal Ozieblo
>> Cc: Nicolas Ferre; harini.katakam@xilinx.com; netdev@vger.kernel.org; li=
nux-kernel@vger.kernel.org
>> Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support fo=
r GEM
>>
>> Hi Rafal,
>>
>> On Thu, Nov 17, 2016 at 7:05 PM, Rafal Ozieblo <rafalo@cadence.com> wrot=
e:
>> > -----Original Message-----
>> > From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
>> > Sent: 17 listopada 2016 14:29
>> > To: Harini Katakam; Rafal Ozieblo
>> > Cc: harini.katakam@xilinx.com; netdev@vger.kernel.org;
>> > linux-kernel@vger.kernel.org
>> > Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support
>> > for GEM
>> >
>> >> Le 17/11/2016 =C3=A0 13:21, Harini Katakam a =C3=A9crit :
>> >> > Hi Rafal,
>> >> >
>> >> > On Thu, Nov 17, 2016 at 5:20 PM, Rafal Ozieblo <rafalo@cadence.com>=
 wrote:
>> >> >> Hello,
>> >> >> I think, there could a bug in your patch.
>> >> >>
>> >> >>> +
>> >> >>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>> >> >>> +             dmacfg |=3D GEM_BIT(ADDR64); #endif
>> >> >>
>> >> >> You enable 64 bit addressing (64b dma bus width) always when appro=
priate architecture config option is enabled.
>> >> >> But there are some legacy controllers which do not support that fe=
ature. According Cadence hardware team:
>> >> >> "64 bit addressing was added in July 2013. Earlier version do not =
have it.
>> >> >> This feature was enhanced in release August 2014 to have separate =
upper address values for transmit and receive."
>> >> >>
>> >> >>> /* Bitfields in NSR */
>> >> >>> @@ -474,6 +479,10 @@
>> >> >>>  struct macb_dma_desc {
>> >> >>  >      u32     addr;
>> >> >>>       u32     ctrl;
>> >> >>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>> >> >>> +     u32     addrh;
>> >> >>> +     u32     resvd;
>> >> >>> +#endif
>> >> >>>  };
>> >> >>
>> >> >> It will not work for legacy hardware. Old descriptor is 2 words wi=
de, the new one is 4 words wide.
>> >> >> If you enable CONFIG_ARCH_DMA_ADDR_T_64BIT but hardware doesn't
>> >> >> support it at all, you will miss every second descriptor.
>> >> >>
>> >> >
>> >> > True, this feature is not available in all of Cadence IP versions.
>> >> > In fact, the IP version Zynq does not support this. But the one in =
ZynqMP does.
>> >> > So, we enable kernel config for 64 bit DMA addressing for this SoC
>> >> > and hence the driver picks it up. My assumption was that if the
>> >> > legacy IP does not support
>> >> > 64 bit addressing, then this DMA option wouldn't be enabled.
>> >> >
>> >> > There is a design config register in Cadence IP which is being read
>> >> > to check for 64 bit address support - DMA mask is set based on that=
.
>> >> > But the addition of two descriptor words cannot be based on this ru=
ntime check.
>> >> > For this reason, all the static changes were placed under this chec=
k.
>> >>
>> >> We have quite a bunch of options in this driver to determinate what i=
s the real capacity of the underlying hardware.
>> >> If HW configuration registers are not appropriate, and it seems they =
are not, I would advice to simply use the DT compatibility string.
>> >>
>> >> Best regards,
>> >> --
>> >> Nicolas Ferre
>> >
>> > HW configuration registers are appropriate. The issue is that this cod=
e doesn=E2=80=99t use the capability bit to switch between different dma de=
scriptors (2 words vs. 4 words).
>> > DMA descriptor size is chosen based on kernel configuration, not based=
 on hardware capabilities.
>>
>> HW configuration register does give appropriate information.
>> But addition of two address words in the macb descriptor structure is a =
static change.
>>
>> +static inline void macb_set_addr(struct macb_dma_desc *desc, dma_addr_t
>> +addr) {
>> +       desc->addr =3D (u32)addr;
>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>> +       desc->addrh =3D (u32)(addr >> 32); #endif
>> +
>>
>> Even if the #ifdef condition here is changed to HW config check, addr an=
d addrh are different.
>> And "addrh" entry has to be present for 64 bit desc case to be handled s=
eparately.
>> Can you please tell me how you propose change in DMA descriptor structur=
e from
>> 4 to 2 or 2 to 4 words *after* reading the DCFG register?
>
> It is very complex problem. I wrote to you because I faced the same issue=
. I'm working on PTP implementation for macb. When PTP is enabled there are=
 additional two words in buffer descriptor.
> But hardware might not be compatible with PTP. Therefore I have to change=
 DMA descriptor between 2 and 4 words after reading DCFG register (the same=
 as you between 32b and 64b).
> When we consider both PTP and 64 bits, we end up with 4 different descrip=
tors!

Agree

<snip>
> (Below is kind of pseudo code only to show my idea. All defines like 64B =
or PTP are omitted for simplicity)
>
> 1. Prepare appropriate structures:
>
> struct macb_dma_desc {
>         u32     addr;
>         u32     ctrl;
> }
>
> struct macb_dma_desc_64 {
>         u32 addrh;
>         u32 resvd;
> }
>
> struct macb_dma_desc_ptp {
>         u32 dma_desc_ts_1;
>         u32     dma_desc_ts_2;
> }
>
> 2. Add hardware support information to macb:
>
> enum macb_hw_cap {
>         HW_CAP_NONE,
>         HW_CAP_64B,
>         HW_CAP_PTP,
>         HW_CAP_64B_PTP,
> };
>
> struct macb {
> // (...)
>         macb_hw_cap hw_cap;
>
> }
>
> 3. Set bp->hw_cap on macb_probe()
>

hw_cap can alreayd be obtained from config structures
based on compatible string.

> 4. Additional function might be helpful:
>
> static unsigned char macb_dma_desc_get_mul(struct macb *bp)
> {
>         switch (bp->hw_cap) {
>                 case HW_CAP_NONE:
>                         return 1;
>                 case HW_CAP_64B:
>                 case HW_CAP_PTP:
>                         return 2;
>                 case HW_CAP_64B_PTP:
>                         return 3;
>         }
> }
>
> 5. Change sizeof struct to function:
> (sizeof(struct macb_dma_desc) change to macb_dma_desc_get_size(bp). It wi=
ll return sizeof(struct macb_dma_desc) * macb_dma_desc_get_mul(bp).
> There is a hidden assumption that all three structures have the same size=
.
>
> 6. macb_rx_desc() and macb_tx_desc() will still return struct macb_dma_de=
sc * but descriptor index will be counted in different way, ex.
>
> static struct macb_dma_desc *macb_rx_desc(struct macb *bp, unsigned int i=
ndex)
> {
>         index *=3D macb_dma_desc_get_mul(bp);
>         return &bp->rx_ring[macb_rx_ring_wrap(bp, index)];
> }
>
> 7. Two additional functions to dereference PTP and 64b information:
>
> static struct macb_dma_desc_64 *macb_64b_desc(struct macb *bp, struct mac=
b_dma_desc *desc)
> {
>         switch (bp->hw_cap) {
>                 case HW_CAP_64B:
>                 case HW_CAP_64B_PTP:
>                         return (struct macb_dma_desc_64 *)(desc + 1);  //=
 ugly casting
>                 default:
>                         return NULL;
>         }
> }
>
> static struct macb_dma_desc_ptp *macb_ptp_desc(struct macb *bp, struct ma=
cb_dma_desc *desc)
> {
>         switch (bp->hw_cap) {
>                 case HW_CAP_PTP:
>                         return (struct macb_dma_desc_ptp *)(desc + 1);
>                 case HW_CAP_64B_PTP:
>                         return (struct macb_dma_desc_ptp *)(desc + 2);
>                 default:
>                         return NULL;
>         }
> }
>
> Whenever you want to reach fields in appropriate descriptor, above functi=
on should be used.
>

Theoretically I agree this will work.
But we'll have to try to see how this will affect/slow down
the desc reading.. especially with PTP.

Regards,
Harini

> This is only my very first idea. Of course, we can leave it as it is and =
say, that old hardware is not support either when PTP enabled or 64b enable=
d.
