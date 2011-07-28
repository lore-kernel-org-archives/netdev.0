From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Oops when insmod rtl8192ce
Date: Thu, 28 Jul 2011 09:56:15 -0500
Message-ID: <4E31788F.7000307@lwfinger.net>
References: <CAMzZzFGqPv6Nbw8J8JGNKcLA76sAs3oD6+hH9NPCjwA33fYpOQ@mail.gmail.com>	<20110727135353.GA16431@tuxdriver.com> <CAMzZzFH8xBdiEN-rV1XE-1ZhFbzO_tcnA75Hpx_AyJ6LtWq01A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>, wlanfae@realtek.com,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hubert Liao <liao.hubertt@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMzZzFH8xBdiEN-rV1XE-1ZhFbzO_tcnA75Hpx_AyJ6LtWq01A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/2011 02:06 AM, hubert Liao wrote:
> 2011/7/27 John W. Linville<linville@tuxdriver.com>:
>> On Wed, Jul 27, 2011 at 05:20:15PM +0800, hubert Liao wrote:
>>> Hi,
>>>
>>> We got an oops when insmod rtl8192ce module (the board is an ARM so=
c),
>>> accroding the oops message, find it's because in rtl_pci_probe() ca=
lled
>>> _rtl_pci_find_adapter(),
>>> in this funcation, the  pdev->bus->self is a NULL pointer .
>>>
>>> static boot _rtl_pci_find_adapter(strcut pci_dev *dev,
>>>                struct ieee80211_hw *hw)
>>> {
>>>
>>> struct pci_dev *bridge_pdev =3D pdev->bus->self;   //line 1601
>>> ...
>>>
>>> pcipriv->ndis_adapter.pcibridge_vendorid =3D bridge_pdev->vendor;<-=
- [oops
>>> here] line 1700
>>>
>>> ...
>>> }
>>>
>>> here, I just want to know why the bus->self  is NULL?
>>
>> pdev is coming straight from what is passed to the PCI probe routine=
=2E
>> It seems like pdev->bus->self should already be set before that
>> happens.
>>
> Yes, I think it should be initialized when added the pci bus bridge,
> I have checked the mach-kirkwood(my board is arch/arm/mach-kirkwood)
> pcie related code, and I think when system initialized should call
> kirkwood_pcie_init() ->
>              kirkwood_pcie_scan_bus() ->
>                             pci_scan_bus() ->
>                                      pci_bus_add_devices()
> if the pci_bus->self  was initialized in pci_bus_add_devices()?
> Maybe the code is too complex for me ,  I really can not find where
> set the =93->self" member?

I added a request to the bugzilla entry to post the full dmesg output t=
here.=20
Perhaps there is some clue in the bus setup.

Larry
