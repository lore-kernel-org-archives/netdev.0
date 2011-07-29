From: Hubert Liao <liao.hubertt@gmail.com>
Subject: Re: Oops when insmod rtl8192ce
Date: Fri, 29 Jul 2011 09:21:35 +0800
Message-ID: <CAMzZzFF2WYGxEi5dmVKmDLG2zq4O0ZFzi65TxYGp1nAUdaVLnA@mail.gmail.com>
References: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com>
	<20110727135353.GA16431@tuxdriver.com>
	<CAMzZzFH8xBdiEN-rV1XE-1ZhFbzO_tcnA75Hpx_AyJ6LtWq01A@mail.gmail.com>
	<4E31788F.7000307@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>, wlanfae@realtek.com,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:50087 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab1G2BVh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 21:21:37 -0400
In-Reply-To: <4E31788F.7000307@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/28 Larry Finger <Larry.Finger@lwfinger.net>:
> On 07/28/2011 02:06 AM, hubert Liao wrote:
>>
>> 2011/7/27 John W. Linville<linville@tuxdriver.com>:
>>>
>>> On Wed, Jul 27, 2011 at 05:20:15PM +0800, hubert Liao wrote:
>>>>
>>>> Hi,
>>>>
>>>> We got an oops when insmod rtl8192ce module (the board is an ARM s=
oc),
>>>> accroding the oops message, find it's because in rtl_pci_probe() c=
alled
>>>> _rtl_pci_find_adapter(),
>>>> in this funcation, the =A0pdev->bus->self is a NULL pointer .
>>>>
>>>> static boot _rtl_pci_find_adapter(strcut pci_dev *dev,
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ieee80211_hw *hw)
>>>> {
>>>>
>>>> struct pci_dev *bridge_pdev =3D pdev->bus->self; =A0 //line 1601
>>>> ...
>>>>
>>>> pcipriv->ndis_adapter.pcibridge_vendorid =3D bridge_pdev->vendor;<=
-- [oops
>>>> here] line 1700
>>>>
>>>> ...
>>>> }
>>>>
>>>> here, I just want to know why the bus->self =A0is NULL?
>>>
>>> pdev is coming straight from what is passed to the PCI probe routin=
e.
>>> It seems like pdev->bus->self should already be set before that
>>> happens.
>>>
>> Yes, I think it should be initialized when added the pci bus bridge,
>> I have checked the mach-kirkwood(my board is arch/arm/mach-kirkwood)
>> pcie related code, and I think when system initialized should call
>> kirkwood_pcie_init() ->
>> =A0 =A0 =A0 =A0 =A0 =A0 kirkwood_pcie_scan_bus() ->
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pci_scan_bus(=
) ->
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 pci_bus_add_devices()
>> if the pci_bus->self =A0was initialized in pci_bus_add_devices()?
>> Maybe the code is too complex for me , =A0I really can not find wher=
e
>> set the =93->self" member?
>
> I added a request to the bugzilla entry to post the full dmesg output=
 there.
> Perhaps there is some clue in the bus setup.
>
I have added the full dmesg output on bugzilla.
thanks.
> Larry
>
>
