From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: 4.10.9 nok with realtek wlan, atom
Date: Sun, 16 Apr 2017 14:30:38 -0500
Message-ID: <3cf1997e-621f-b682-07b4-52b3945124ae@lwfinger.net>
References: <CAJs9aZ8HVPn_J9yPjvdBm-A_d3FiquPMGoy1xFsGopF8Xg_89Q@mail.gmail.com>
 <9e48930c-4822-5af4-2ebb-4d2dcd12d448@lwfinger.net>
 <CAJs9aZ9Hwnjb60mCycR3T2TWH75ZTdtEeWQ1iHRN+6NkkD+pZA@mail.gmail.com>
 <40bc6004-519c-7bf1-874b-3ae169140637@lwfinger.net>
 <CAJs9aZ_QRgqAjt+6FV=ZkPvYvkDedwtegMKC4Dk-uT8KtrE-mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <helgaas-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: rupert THURNER <rupert.thurner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJs9aZ_QRgqAjt+6FV=ZkPvYvkDedwtegMKC4Dk-uT8KtrE-mA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/16/2017 01:09 PM, rupert THURNER wrote:
> On Sun, Apr 16, 2017 at 6:02 PM, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
>> On 04/16/2017 05:23 AM, rupert THURNER wrote:
>>>
>>> On Sat, Apr 15, 2017 at 10:40 PM, Larry Finger
>>> <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
>>>>
>>>> On 04/14/2017 03:26 PM, rupert THURNER wrote:
>>>>>
>>>>>
>>>>> On Thu, Feb 9, 2017 at 9:09 PM, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>>>>> wrote:
>>>>>>
>>>>>>
>>>>>> On 02/09/2017 01:43 PM, Bjorn Helgaas wrote:
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> [+cc rtl8192ce folks in case they've seen this]
>>>>>>>
>>>>>>> On Thu, Feb 09, 2017 at 03:45:01PM +0100, rupert THURNER wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> hi,
>>>>>>>>
>>>>>>>> not technical expert enough, i just wanted to give a short user
>>>>>>>> feedback. for realtek wlan on atom, kernels up to 4.9.5 are ok, and
>>>>>>>> kernel 4.10.0-rc7-g926af6273fc6 (arch linux-git version numbering) as
>>>>>>>> well. kernels 4.9.6, 4.9.7, and 4.9.8 fail, i.e. connection to a WLAN
>>>>>>>> hotspot is possible then drops, or connecting to wlan fails
>>>>>>>> alltogether.
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>> Thanks very much for your report, and sorry for the inconvenience.
>>>>>>>
>>>>>>> v4.10-rc7 works, so I guess we don't need to worry about fixing v4.10.
>>>>>>>
>>>>>>> But the stable kernels v4.9.6, v4.9.7, and v4.9.8 are broken, so we
>>>>>>> need to figure out why and make sure we fix the v4.9 stable series.
>>>>>>>
>>>>>>> I can't tell yet whether this is PCI-related or not.  If it is,
>>>>>>> 4922a6a5cfa7 ("PCI: Enumerate switches below PCI-to-PCIe bridges")
>>>>>>> appeared in v4.9.6, and there is a known issue with that.  The issue
>>>>>>> should be fixed by 610c2b7ff8f6 ("PCI/ASPM: Handle PCI-to-PCIe bridges
>>>>>>> as roots of PCIe hierarchies"), which appeared in v4.9.9, so I guess
>>>>>>> the first thing to do would be to test v4.9.9.
>>>>>>>
>>>>>>> If it's not fixed in v4.9.9, can you share the complete dmesg log
>>>>>>> (output of "dmesg" command) and "lspci -vv" output for v4.9.5 (last
>>>>>>> known working version) and v4.9.6 (first known broken version)?  On
>>>>>>> v4.9.6, collect the dmesg output after the failure occurs.
>>>>>>>
>>>>>>>> 24: PCI 300.0: 0282 WLAN controller
>>>>>>>>   [Created at pci.366]
>>>>>>>>   Model: "Realtek RTL8188CE 802.11b/g/n WiFi Adapter"
>>>>>>>>   Device: pci 0x8176 "RTL8188CE 802.11b/g/n WiFi Adapter"
>>>>>>>>   Revision: 0x01
>>>>>>>>   Driver: "rtl8192ce"
>>>>>>>>   Driver Modules: "rtl8192ce"
>>>>>>>>   Device File: wlp3s0
>>>>>>>>   Features: WLAN
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>> It would be helpful if someone were to bisect this issue. The only
>>>>>> issue
>>>>>> that comes to mind was fixed in commit 52f5631a4c05 ("rtlwifi:
>>>>>> rtl8192ce:
>>>>>> Fix loading of incorrect firmware") which is in 4.10-rc7 and will be
>>>>>> backported to 4.9.
>>>>>>
>>>>>> The above issue is one that could not be reproduced on my hardware,
>>>>>> thus
>>>>>> it
>>>>>> took Jurij Smakov to find the fix. Without his bisection of the
>>>>>> problem,
>>>>>> who
>>>>>> knows how long it would have taken to find my edit mistake.
>>>>>
>>>>>
>>>>>
>>>>> larry, using the newest kernel 4.10.8 the network connection dropps
>>>>> again irregular.
>>>>>
>>>>> # dmesg
>>>>> [    0.000000] Linux version 4.10.9-1-ARCH (builduser@tobias) (gcc
>>>>> version 6.3.1 20170306 (GCC) ) #1 SMP PREEMPT Sat Apr 8 12:39:59 CEST
>>>>> 2017
>>>>> [   11.933373] rtl8192ce: rtl8192ce: Power Save off (module option)
>>>>> [   11.933396] rtl8192ce: Using firmware rtlwifi/rtl8192cfw.bin
>>>>> [   11.978307] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
>>>>> [   11.978945] rtlwifi: rtlwifi: wireless switch is on
>>>>>
>>>>> # lspci -vv
>>>>> Subsystem: Realtek Semiconductor Co., Ltd. RTL8188CE 802.11b/g/n WiFi
>>>>> Adapter
>>>>> Kernel driver in use: rtl8192ce
>>>>
>>>>
>>>>
>>>> Is firmware rtlwifi/rtl8192cfw.bin also used on kernels that work?
>>>
>>>
>>> 4.10.x used to work. 4.10.6 or 4.10.7 it started failing? i am not too
>>> sure about it.
>>>
>>> # ls -l /usr/lib/firmware/rtlwifi/rtl8192cfw.bin
>>> -rw-r--r-- 1 root root 16192 Mar 10 12:15
>>> /usr/lib/firmware/rtlwifi/rtl8192cfw.bin
>>
>>
>> That does not answer my question.
> 4.10, 4.10.2, 4.10.3, 4.10.5 worked. as far as i can tell
> rtl8192cfw.bin did not change and was used. with kernels 4.9 there was
> a phase where rtl8192cfwU.bin was loaded which did not work. or i do
> not understand your question correctly?

I think you mean that rtl8192cfw.bin was the firmware used for both a good and a 
bad kernel.

My problem is that there are at least 6 varieties of chips that use the 
rtl8192ce driver. I do not have all of them, but so far it is impossible for me 
to tell if yours is the same as one of mine. If you post the output of 'lspci 
-nn', then I might be able to answer that question.

A second problem is that there are no fixes in any 4.10.x kernel where x >= 1 
that can cause a problem in rtl8192ce, thus it is hard to know how 4.10.5 can 
work and 4.10.6 or 7 can fail! That is the reason that a bisection would be useful.

At this point, and with the information you have provided, I'm not sure if the 
problem is even in rtl8192ce, or how I can help.

Larry
