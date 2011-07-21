From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/2] igb: Allow extra 4 bytes on RX for vlan tags.
Date: Thu, 21 Jul 2011 14:44:28 -0700
Message-ID: <CAEP_g=-XqsgG29Jj9GNMY3FpXMwxRW7TCg=oYarvM3QsHNwheQ@mail.gmail.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
 <AANLkTinsWRAJ2bepa1NjQ4f0Wz46DaxWO6f_nEbmBAB0@mail.gmail.com>
 <4D5D5AD8.5000802@candelatech.com> <CAEP_g=_o7nP2FCnPufyT44JZZ+Z+jkcVpSa8Qj3mjPn+MwRhXA@mail.gmail.com>
 <4E277267.8090702@candelatech.com> <1311211304.2401.9.camel@jtkirshe-mobl> <CAKgT0UfaEEvRTSpu-U+0_oj0KnEkyx5hRAwZDiCAAdtY4YhQUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:42470 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820Ab1GUVot convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 17:44:49 -0400
Received: by yia27 with SMTP id 27so868334yia.19
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 14:44:48 -0700 (PDT)
In-Reply-To: <CAKgT0UfaEEvRTSpu-U+0_oj0KnEkyx5hRAwZDiCAAdtY4YhQUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 11:35 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, Jul 20, 2011 at 6:21 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> On Wed, 2011-07-20 at 17:27 -0700, Ben Greear wrote:
>>> On 07/20/2011 05:18 PM, Jesse Gross wrote:
>>> > On Thu, Feb 17, 2011 at 9:28 AM, Ben Greear<greearb@candelatech.c=
om> =C2=A0wrote:
>>> >> On 02/17/2011 03:04 AM, Jeff Kirsher wrote:
>>> >>>
>>> >>> On Thu, Feb 10, 2011 at 13:59,<greearb@candelatech.com> =C2=A0 =
=C2=A0wrote:
>>> >>>>
>>> >>>> From: Ben Greear<greearb@candelatech.com>
>>> >>>>
>>> >>>> This allows the NIC to receive 1518 byte (not counting
>>> >>>> FCS) packets when MTU is 1500, thus allowing 1500 MTU
>>> >>>> VLAN frames to be received. =C2=A0Please note that no VLANs
>>> >>>> were actually configured on the NIC...it was just acting
>>> >>>> as pass-through device.
>>> >>>>
>>> >>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>> >>>> ---
>>> >>>> :100644 100644 58c665b... 30c9cc6... M =C2=A0drivers/net/igb/i=
gb_main.c
>>> >>>> =C2=A0 drivers/net/igb/igb_main.c | =C2=A0 =C2=A05 +++--
>>> >>>> =C2=A0 1 files changed, 3 insertions(+), 2 deletions(-)
>>> >>>>
>>> >>>> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_=
main.c
>>> >>>> index 58c665b..30c9cc6 100644
>>> >>>> --- a/drivers/net/igb/igb_main.c
>>> >>>> +++ b/drivers/net/igb/igb_main.c
>>> >>>> @@ -2281,7 +2281,8 @@ static int __devinit igb_sw_init(struct =
igb_adapter
>>> >>>> *adapter)
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 adapter->rx_itr_setting =3D IGB_DE=
=46AULT_ITR;
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 adapter->tx_itr_setting =3D IGB_DE=
=46AULT_ITR;
>>> >>>>
>>> >>>> - =C2=A0 =C2=A0 =C2=A0 adapter->max_frame_size =3D netdev->mtu=
 + ETH_HLEN + ETH_FCS_LEN;
>>> >>>> + =C2=A0 =C2=A0 =C2=A0 adapter->max_frame_size =3D (netdev->mt=
u + ETH_HLEN + ETH_FCS_LEN
>>> >>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0+ VLAN_HLEN);
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 adapter->min_frame_size =3D ETH_ZL=
EN + ETH_FCS_LEN;
>>> >>>>
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&adapter->stats64_l=
ock);
>>> >>>> @@ -4303,7 +4304,7 @@ static int igb_change_mtu(struct net_dev=
ice
>>> >>>> *netdev, int new_mtu)
>>> >>>> =C2=A0 {
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct igb_adapter *adapter =3D ne=
tdev_priv(netdev);
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct pci_dev *pdev =3D adapter->=
pdev;
>>> >>>> - =C2=A0 =C2=A0 =C2=A0 int max_frame =3D new_mtu + ETH_HLEN + =
ETH_FCS_LEN;
>>> >>>> + =C2=A0 =C2=A0 =C2=A0 int max_frame =3D new_mtu + ETH_HLEN + =
ETH_FCS_LEN + VLAN_HLEN;
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 rx_buffer_len, i;
>>> >>>>
>>> >>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((new_mtu< =C2=A0 =C2=A068) || =
(max_frame> =C2=A0 =C2=A0MAX_JUMBO_FRAME_SIZE)) {
>>> >>>
>>> >>> While testing this patch, validation found that the patch reduc=
es the
>>> >>> maximum mtu size
>>> >>> by 4 bytes (reduces it from 9216 to 9212). =C2=A0This is not a =
desired side
>>> >>> effect of this patch.
>>> >>
>>> >> You could add handling for that case and have it act as it used =
to when
>>> >> new_mtu is greater than 9212?
>>> >>
>>> >> I tested e1000e and it worked w/out hacking at 1500 MTU, so mayb=
e
>>> >> check how it does it?
>>> >
>>> > I just wanted to bring this up again to see if any progress had b=
een
>>> > made. =C2=A0We were looking at this driver and trying to figure o=
ut the
>>> > best way to convert it to use the new vlan model but I'm not fami=
liar
>>>
>>> I've been watching :)
>>>
>>> > enough with the hardware to know. =C2=A0It seems that all of the =
other
>>> > Intel drivers unconditionally add space for the vlan tag to the
>>> > receive buffer (and would therefore have similar effects as this
>>> > patch), is there something different about this card?
>>> >
>>> > I believe that Alex was working on something in this area (in the
>>> > context of one of my patches from a long time ago) but I'm not su=
re
>>> > what came of that.
>>>
>>> Truth is, I don't really see why it's a problem to decrease the
>>> maximum MTU slightly in order to make it work with VLANs.
>>>
>>> I'm not sure if there is some way to make it work with VLANs
>>> and not decrease the maximum MTU.
>>
>> This was the reason this did not get accepted. =C2=A0I was looking i=
nto what
>> could be done so that we did not decease the maximum MTU, but I got
>> side-tracked and have not done anything on it in several months.
>>
>
> I can take a look at fixing this most likely tomorrow. =C2=A0I have s=
ome
> work planned for igb anyway over the next few days.
>
> Odds are it is just a matter of where the VLAN_HLEN is added. =C2=A0A=
s I
> recall for our drivers the correct spot is in the setting of
> rx_buffer_len since that is the area more concerned with maximum
> receive frame size versus the mtu section which is more concerned wit=
h
> the transmit side of things.

Thanks Alex.
