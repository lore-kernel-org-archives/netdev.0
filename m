From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: linux <=4.9.5, 4.10-rc7 ok, 4.9.6 - 4.9.8 nok with realtek wlan,
 atom
Date: Thu, 9 Feb 2017 14:09:21 -0600
Message-ID: <da188e74-3c2b-10ba-9c4e-21b691cc2b31@lwfinger.net>
References: <CAJs9aZ9FqU-NCj2egBp6J06uD_Qp3Lje=mSSVbV4vNcYGKdumA@mail.gmail.com>
 <20170209194321.GC11905@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Bjorn Helgaas <helgaas@kernel.org>,
        rupert THURNER <rupert.thurner@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170209194321.GC11905@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/09/2017 01:43 PM, Bjorn Helgaas wrote:
> [+cc rtl8192ce folks in case they've seen this]
>
> On Thu, Feb 09, 2017 at 03:45:01PM +0100, rupert THURNER wrote:
>> hi,
>>
>> not technical expert enough, i just wanted to give a short user
>> feedback. for realtek wlan on atom, kernels up to 4.9.5 are ok, and
>> kernel 4.10.0-rc7-g926af6273fc6 (arch linux-git version numbering) as
>> well. kernels 4.9.6, 4.9.7, and 4.9.8 fail, i.e. connection to a WLAN
>> hotspot is possible then drops, or connecting to wlan fails
>> alltogether.
>
> Thanks very much for your report, and sorry for the inconvenience.
>
> v4.10-rc7 works, so I guess we don't need to worry about fixing v4.10.
>
> But the stable kernels v4.9.6, v4.9.7, and v4.9.8 are broken, so we
> need to figure out why and make sure we fix the v4.9 stable series.
>
> I can't tell yet whether this is PCI-related or not.  If it is,
> 4922a6a5cfa7 ("PCI: Enumerate switches below PCI-to-PCIe bridges")
> appeared in v4.9.6, and there is a known issue with that.  The issue
> should be fixed by 610c2b7ff8f6 ("PCI/ASPM: Handle PCI-to-PCIe bridges
> as roots of PCIe hierarchies"), which appeared in v4.9.9, so I guess
> the first thing to do would be to test v4.9.9.
>
> If it's not fixed in v4.9.9, can you share the complete dmesg log
> (output of "dmesg" command) and "lspci -vv" output for v4.9.5 (last
> known working version) and v4.9.6 (first known broken version)?  On
> v4.9.6, collect the dmesg output after the failure occurs.
>
>> 24: PCI 300.0: 0282 WLAN controller
>>   [Created at pci.366]
>>   Model: "Realtek RTL8188CE 802.11b/g/n WiFi Adapter"
>>   Device: pci 0x8176 "RTL8188CE 802.11b/g/n WiFi Adapter"
>>   Revision: 0x01
>>   Driver: "rtl8192ce"
>>   Driver Modules: "rtl8192ce"
>>   Device File: wlp3s0
>>   Features: WLAN

It would be helpful if someone were to bisect this issue. The only issue that 
comes to mind was fixed in commit 52f5631a4c05 ("rtlwifi: rtl8192ce: Fix loading 
of incorrect firmware") which is in 4.10-rc7 and will be backported to 4.9.

The above issue is one that could not be reproduced on my hardware, thus it took 
Jurij Smakov to find the fix. Without his bisection of the problem, who knows 
how long it would have taken to find my edit mistake.

Larry
