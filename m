From: hubert Liao <liao.hubertt@gmail.com>
Subject: Re: Oops when insmod rtl8192ce
Date: Thu, 28 Jul 2011 15:06:52 +0800
Message-ID: <CAMzZzFH8xBdiEN-rV1XE-1ZhFbzO_tcnA75Hpx_AyJ6LtWq01A@mail.gmail.com>
References: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com>
	<20110727135353.GA16431@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: wlanfae@realtek.com, Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:48495 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1G1HGx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 03:06:53 -0400
In-Reply-To: <20110727135353.GA16431@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/27 John W. Linville <linville@tuxdriver.com>:
> On Wed, Jul 27, 2011 at 05:20:15PM +0800, hubert Liao wrote:
>> Hi,
>>
>> We got an oops when insmod rtl8192ce module (the board is an ARM soc=
),
>> accroding the oops message, find it's because in rtl_pci_probe() cal=
led
>> _rtl_pci_find_adapter(),
>> in this funcation, the =A0pdev->bus->self is a NULL pointer .
>>
>> static boot _rtl_pci_find_adapter(strcut pci_dev *dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ieee80211_hw *hw)
>> {
>>
>> struct pci_dev *bridge_pdev =3D pdev->bus->self; =A0 //line 1601
>> ...
>>
>> pcipriv->ndis_adapter.pcibridge_vendorid =3D bridge_pdev->vendor; <-=
- [oops
>> here] line 1700
>>
>> ...
>> }
>>
>> here, I just want to know why the bus->self =A0is NULL?
>
> pdev is coming straight from what is passed to the PCI probe routine.
> It seems like pdev->bus->self should already be set before that
> happens.
>
Yes, I think it should be initialized when added the pci bus bridge,
I have checked the mach-kirkwood(my board is arch/arm/mach-kirkwood)
pcie related code, and I think when system initialized should call
kirkwood_pcie_init() ->
            kirkwood_pcie_scan_bus() ->
                           pci_scan_bus() ->
                                    pci_bus_add_devices()
if the pci_bus->self  was initialized in pci_bus_add_devices()?
Maybe the code is too complex for me ,  I really can not find where
set the =93->self" member?

> Please open a bug at bugzilla.kernel.org to help us keep track of
> this -- thanks!
>
I have committed it the url,
https://bugzilla.kernel.org/show_bug.cgi?id=3D40212
> John
> --
> John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world wil=
l need a hero, and you
> linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be al=
l we have. =A0Be ready.
>
