From: Arnaud Lacombe <lacombar@gmail.com>
Subject: Re: [net-next 1/9] igb: Update RXDCTL/TXDCTL configurations
Date: Sun, 2 Oct 2011 21:47:48 -0400
Message-ID: <CACqU3MWpJh8+PGOG=UYidwnk3Yds0D3VEsfpKh44GEwWf-u2bA@mail.gmail.com>
References: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1316502690-25488-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<CACqU3MV64hahK0s7nDqNaRemZiygq33BgaY6_v9hh0iKX42Mfw@mail.gmail.com>
	<4E84E344.2090201@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39361 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab1JCBru convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 21:47:50 -0400
Received: by wwf22 with SMTP id 22so5156468wwf.1
        for <netdev@vger.kernel.org>; Sun, 02 Oct 2011 18:47:48 -0700 (PDT)
In-Reply-To: <4E84E344.2090201@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Sep 29, 2011 at 5:29 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> This is due to a HW errata. =A0Specifically HW errata 26 in the spec =
update at
> http://download.intel.com/design/network/specupdt/82576_SPECUPDATE.pd=
f.
>
> It essentially states that write back does not occur on MSI-X interru=
pt
> events so we need to keep WTHRESH at 1 in order to avoid any false ha=
ngs.
>
Could it be possible in the future to include this kind of information
in the commit log ? That might always be useful in a few years when
trying to understand why the code has such or such limitation.

Thanks!
 - Arnaud

> Thanks,
>
> Alex
>
> On 09/29/2011 10:41 AM, Arnaud Lacombe wrote:
>>
>> Hi,
>>
>> On Tue, Sep 20, 2011 at 3:11 AM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> =A0wrote:
>>>
>>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>>>
>>> This change cleans up the RXDCTL and TXDCTL configurations and opti=
mizes
>>> RX
>>> performance by allowing back write-backs on all hardware other than
>>> 82576.
>>>
>> Where does this limitation comes from ? The "Intel 82576EB GbE
>> Controller - Programming Interface" from May 2011 advertises that bo=
th
>> the RXDCTL and TXDCTL register have a 5bit wide WTHRESH field.
>>
>> Thanks,
>> =A0- Arnaud
>>
>>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>>> Tested-by: =A0Aaron Brown<aaron.f.brown@intel.com>
>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>> ---
>>> =A0drivers/net/ethernet/intel/igb/igb.h =A0 =A0 =A0| =A0 =A05 +++--
>>> =A0drivers/net/ethernet/intel/igb/igb_main.c | =A0 23 +++++++++----=
----------
>>> =A02 files changed, 12 insertions(+), 16 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/igb/igb.h
>>> b/drivers/net/ethernet/intel/igb/igb.h
>>> index 265e151..577fd3e 100644
>>> --- a/drivers/net/ethernet/intel/igb/igb.h
>>> +++ b/drivers/net/ethernet/intel/igb/igb.h
>>> @@ -100,11 +100,12 @@ struct vf_data_storage {
>>> =A0*/
>>> =A0#define IGB_RX_PTHRESH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8
>>> =A0#define IGB_RX_HTHRESH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8
>>> -#define IGB_RX_WTHRESH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1
>>> =A0#define IGB_TX_PTHRESH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8
>>> =A0#define IGB_TX_HTHRESH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1
>>> +#define IGB_RX_WTHRESH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((h=
w->mac.type =3D=3D
>>> e1000_82576&& =A0\
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0adapter->msix_entries) ? 1 :
>>> 4)
>>> =A0#define IGB_TX_WTHRESH =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (=
(hw->mac.type =3D=3D
>>> e1000_82576&& =A0\
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 adapter->msix_entries) ? 1
>>> : 16)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0adapter->msix_entries) ? 1 :
>>> 16)
>>>
>>> =A0/* this is the size past which hardware will drop packets when s=
etting
>>> LPE=3D0 */
>>> =A0#define MAXIMUM_ETHERNET_VLAN_SIZE 1522
>>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>>> b/drivers/net/ethernet/intel/igb/igb_main.c
>>> index 3cb1bc9..aa78c10 100644
>>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>>> @@ -2666,14 +2666,12 @@ void igb_configure_tx_ring(struct igb_adapt=
er
>>> *adapter,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct igb_r=
ing *ring)
>>> =A0{
>>> =A0 =A0 =A0 =A0struct e1000_hw *hw =3D&adapter->hw;
>>> - =A0 =A0 =A0 u32 txdctl;
>>> + =A0 =A0 =A0 u32 txdctl =3D 0;
>>> =A0 =A0 =A0 =A0u64 tdba =3D ring->dma;
>>> =A0 =A0 =A0 =A0int reg_idx =3D ring->reg_idx;
>>>
>>> =A0 =A0 =A0 =A0/* disable the queue */
>>> - =A0 =A0 =A0 txdctl =3D rd32(E1000_TXDCTL(reg_idx));
>>> - =A0 =A0 =A0 wr32(E1000_TXDCTL(reg_idx),
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 txdctl& =A0~E1000_TXD=
CTL_QUEUE_ENABLE);
>>> + =A0 =A0 =A0 wr32(E1000_TXDCTL(reg_idx), 0);
>>> =A0 =A0 =A0 =A0wrfl();
>>> =A0 =A0 =A0 =A0mdelay(10);
>>>
>>> @@ -2685,7 +2683,7 @@ void igb_configure_tx_ring(struct igb_adapter
>>> *adapter,
>>>
>>> =A0 =A0 =A0 =A0ring->head =3D hw->hw_addr + E1000_TDH(reg_idx);
>>> =A0 =A0 =A0 =A0ring->tail =3D hw->hw_addr + E1000_TDT(reg_idx);
>>> - =A0 =A0 =A0 writel(0, ring->head);
>>> + =A0 =A0 =A0 wr32(E1000_TDH(reg_idx), 0);
>>> =A0 =A0 =A0 =A0writel(0, ring->tail);
>>>
>>> =A0 =A0 =A0 =A0txdctl |=3D IGB_TX_PTHRESH;
>>> @@ -3028,12 +3026,10 @@ void igb_configure_rx_ring(struct igb_adapt=
er
>>> *adapter,
>>> =A0 =A0 =A0 =A0struct e1000_hw *hw =3D&adapter->hw;
>>> =A0 =A0 =A0 =A0u64 rdba =3D ring->dma;
>>> =A0 =A0 =A0 =A0int reg_idx =3D ring->reg_idx;
>>> - =A0 =A0 =A0 u32 srrctl, rxdctl;
>>> + =A0 =A0 =A0 u32 srrctl =3D 0, rxdctl =3D 0;
>>>
>>> =A0 =A0 =A0 =A0/* disable the queue */
>>> - =A0 =A0 =A0 rxdctl =3D rd32(E1000_RXDCTL(reg_idx));
>>> - =A0 =A0 =A0 wr32(E1000_RXDCTL(reg_idx),
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxdctl& =A0~E1000_RXD=
CTL_QUEUE_ENABLE);
>>> + =A0 =A0 =A0 wr32(E1000_RXDCTL(reg_idx), 0);
>>>
>>> =A0 =A0 =A0 =A0/* Set DMA base address registers */
>>> =A0 =A0 =A0 =A0wr32(E1000_RDBAL(reg_idx),
>>> @@ -3045,7 +3041,7 @@ void igb_configure_rx_ring(struct igb_adapter
>>> *adapter,
>>> =A0 =A0 =A0 =A0/* initialize head and tail */
>>> =A0 =A0 =A0 =A0ring->head =3D hw->hw_addr + E1000_RDH(reg_idx);
>>> =A0 =A0 =A0 =A0ring->tail =3D hw->hw_addr + E1000_RDT(reg_idx);
>>> - =A0 =A0 =A0 writel(0, ring->head);
>>> + =A0 =A0 =A0 wr32(E1000_RDH(reg_idx), 0);
>>> =A0 =A0 =A0 =A0writel(0, ring->tail);
>>>
>>> =A0 =A0 =A0 =A0/* set descriptor configuration */
>>> @@ -3076,13 +3072,12 @@ void igb_configure_rx_ring(struct igb_adapt=
er
>>> *adapter,
>>> =A0 =A0 =A0 =A0/* set filtering for VMDQ pools */
>>> =A0 =A0 =A0 =A0igb_set_vmolr(adapter, reg_idx& =A00x7, true);
>>>
>>> - =A0 =A0 =A0 /* enable receive descriptor fetching */
>>> - =A0 =A0 =A0 rxdctl =3D rd32(E1000_RXDCTL(reg_idx));
>>> - =A0 =A0 =A0 rxdctl |=3D E1000_RXDCTL_QUEUE_ENABLE;
>>> - =A0 =A0 =A0 rxdctl&=3D 0xFFF00000;
>>> =A0 =A0 =A0 =A0rxdctl |=3D IGB_RX_PTHRESH;
>>> =A0 =A0 =A0 =A0rxdctl |=3D IGB_RX_HTHRESH<< =A08;
>>> =A0 =A0 =A0 =A0rxdctl |=3D IGB_RX_WTHRESH<< =A016;
>>> +
>>> + =A0 =A0 =A0 /* enable receive descriptor fetching */
>>> + =A0 =A0 =A0 rxdctl |=3D E1000_RXDCTL_QUEUE_ENABLE;
>>> =A0 =A0 =A0 =A0wr32(E1000_RXDCTL(reg_idx), rxdctl);
>>> =A0}
>>>
>>> --
>>> 1.7.6.2
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
