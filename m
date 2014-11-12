From: =?ISO-8859-1?Q?Murilo_Opsfelder_Ara=FAjo?= <mopsfelder@gmail.com>
Subject: Re: [PATCH] rtlwifi: Add more checks for get_btc_status callback
Date: Wed, 12 Nov 2014 21:03:42 -0200
Message-ID: <CA+LKeY6xca=f-qFJoVFaqywRpfHPmMAWDrMmbkUiDf9atA_jVQ@mail.gmail.com>
References: <1414625302-3654-1-git-send-email-mopsfelder@gmail.com>
 <5451BED0.2060906@lwfinger.net> <1415178975.5402.66.camel@marge.simpson.net>
 <545A6894.7040506@lwfinger.net> <545B5E19.7030704@gmail.com>
 <545BFBB4.3040005@gmail.com> <545C0487.1090707@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>,
	=?GB2312?B?zLe6vLKo?= <troy_tan@realsil.com.cn>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <545C0487.1090707@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 6, 2014 at 9:30 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> On 11/06/2014 04:52 PM, Murilo Opsfelder Araujo wrote:
>>
>> On 11/06/2014 09:40 AM, Murilo Opsfelder Araujo wrote:
>>>
>>> On 11/05/2014 04:12 PM, Larry Finger wrote:
>>>>
>>>> On 11/05/2014 03:16 AM, Mike Galbraith wrote:
>>>>>
>>>>> On Wed, 2014-10-29 at 23:30 -0500, Larry Finger wrote:
>>>>>>
>>>>>> On 10/29/2014 06:28 PM, Murilo Opsfelder Araujo wrote:
>>>>>>>
>>>>>>> This is a complement of commit
>>>>>>> 08054200117a95afc14c3d2ed3a38bf4e345bf78
>>>>>>> "rtlwifi: Add check for get_btc_status callback".
>>>>>>>
>>>>>>> With this patch, next-20141029 at least does not panic with rtl8192se
>>>>>>> device.
>>>>>>>
>>>>>>
>>>>>> This patch is OK, but as noted it is not complete.
>>>>>>
>>>>>> I have patches to fix all the kernel panics for rtl8192se AND
>>>>>> rtl8192ce. There
>>>>>> are missing parts, but I would prefer submitting mine, which would
>>>>>> conflict with
>>>>>> this one. For that reason, NACK for this one, and please apply the
>>>>>> set I am
>>>>>> submitting now.
>>>>>
>>>>>
>>>>> It's all in there now, but my RTL8191SEvB is still dead.  Squabbling
>>>>> with it isn't going all that well either.
>>>>>
>>>>> As soon as 38506ece rtlwifi: rtl_pci: Start modification for new
>>>>> drivers
>>>>> is applied, explosions appear.  Subsequently applying...
>>>>>
>>>>> 08054200 rtlwifi: Add check for get_btc_status callback
>>>>> c0386f15 rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for
>>>>> missing get_btc_status
>>>>> 50147969 rtlwifi: rtl8192se: Fix duplicate calls to
>>>>> ieee80211_register_hw()
>>>>> 30c5ccc6 rtlwifi: rtl8192se: Add missing section to read descriptor
>>>>> setting
>>>>> 75a916e1 rtlwifi: rtl8192se: Fix firmware loading
>>>>>
>>>>> ...fixes that mess up, but leaves the interface dead in the same manner
>>>>> as if nothing has been reverted.  So it _seems_ the bustage lurks in
>>>>> 38506ece somewhere.  Too bad it's non-dinky, and written in wifi-ese :)
>>>>
>>>>
>>>> Yes, I am aware that rtl8192se is failing, and now that I am back from
>>>> vacation, I am working on the problem. If you want to use the driver
>>>> with kernel 3.18, clone the repo at
>>>> http://github.com/lwfinger/rtlwifi_new.git and build and install either
>>>> the master or kernel_version branches. Both work.
>>>>
>>>> I am in the process of trying to find what the crucial difference is
>>>> between that repo and the kernel version.
>>>>
>>>> Larry
>>>>
>>>>
>>> I'm sending to everyone so others can jump in as well.
>>>
>>> Here are the steps I've followed.
>>>
>>> Installed and booted my kernel:
>>>
>>> $ sudo dpkg -i
>>> linux-image-3.18.0-rc3-next-20141105-panda_3.18.0-rc3-next-20141105-panda-1_amd64.deb
>>> linux-headers-3.18.0-rc3-next-20141105-panda_3.18.0-rc3-next-20141105-panda-1_amd64.deb
>>>
>>> Built modules from Larry's github repository.
>>>
>>> $ cd rtlwifi_new
>>> $ make
>>> $ sudo make install
>>>
>>> $ sudo modprobe -rv rtl8192se
>>> rmmod rtl8192se
>>> rmmod rtl_pci
>>> rmmod rtlwifi
>>> rmmod mac80211
>>> rmmod cfg80211
>>>
>>> The module does not load:
>>>
>>> $ sudo modprobe -v rtl8192se
>>> insmod
>>> /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/net/wireless/cfg80211.ko
>>> insmod
>>> /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/net/mac80211/mac80211.ko
>>> insmod
>>> /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/drivers/net/wireless/rtlwifi/rtlwifi.ko
>>> insmod
>>> /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/drivers/net/wireless/rtlwifi/rtl_pci.ko
>>> insmod /lib/modules/3.18.0-rc3-next-20141105-panda/extra/rtl8192se.ko
>>> ERROR: could not insert 'rtl8192se': Invalid argument
>>>
>>> And /var/log/messages showed:
>>>
>>> Nov  5 22:28:01 laptop kernel: [  301.276806] rtl8192se: disagrees about
>>> version of symbol rtl_process_phyinfo
>>> Nov  5 22:28:01 laptop kernel: [  301.276812] rtl8192se: Unknown symbol
>>> rtl_process_phyinfo (err -22)
>>> Nov  5 22:28:01 laptop kernel: [  301.276864] rtl8192se: disagrees about
>>> version of symbol rtl_get_tcb_desc
>>> Nov  5 22:28:01 laptop kernel: [  301.276866] rtl8192se: Unknown symbol
>>> rtl_get_tcb_desc (err -22)
>>>
>>
>> Here is what I did in order to get the rtl8192se from Larry's repo to
>> work:
>>
>> $ cd rtlwifi_new
>> $ make
>>
>> $ sudo modprobe -rv rtl8192se
>> rmmod rtl8192se
>> rmmod rtl_pci
>> rmmod rtlwifi
>> rmmod mac80211
>> rmmod cfg80211
>>
>> $ sudo modprobe -v cfg80211
>> insmod
>> /lib/modules/3.18.0-rc3-next-20141106-panda/kernel/net/wireless/cfg80211.ko
>>
>> $ sudo modprobe -v mac80211
>> insmod
>> /lib/modules/3.18.0-rc3-next-20141106-panda/kernel/net/mac80211/mac80211.ko
>>
>> $ sudo insmod ./rtlwifi.ko
>> $ sudo insmod ./rtl_pci.ko
>> $ sudo insmod ./rtl8192se/rtl8192se.ko
>>
>> Cascardo helped me to investigate this and the issue was that modprobe
>> was loading the core rtl drivers from the next-20141105 and the
>> rtl8192se from Larry's repo.  Thus, rtl8192se didn't have all its
>> required symbols at loading time.
>>
>> Loading the drivers in reverse order using insmod did the trick.
>>
>> Larry, your rtl8192se from rtlwifi_new repository is working pretty
>> fine on my hardware.  I'm looking forward to see that code landing
>> linux 3.18.
>
>
> I am happy that it is working now; however, if you had done "sudo make
> install", the new drivers would have been in the proper directories, and you
> would not have gotten the incorrect symbol errors, or need to use the insmod
> commands that you post.
>
> Larry
>
>
Hello, Larry.

I'd like to let you know that next-20141112 brought my rtl8192se
device back to life.  I didn't need to build rtlwifi_new to be able to
connect to my wifi network.  It worked just fine.

Thank you all.

-- 
Murilo
