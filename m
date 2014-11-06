From: Murilo Opsfelder Araujo <mopsfelder@gmail.com>
Subject: Re: [PATCH] rtlwifi: Add more checks for get_btc_status callback
Date: Thu, 06 Nov 2014 09:40:09 -0200
Message-ID: <545B5E19.7030704@gmail.com>
References: <1414625302-3654-1-git-send-email-mopsfelder@gmail.com>	 <5451BED0.2060906@lwfinger.net> <1415178975.5402.66.camel@marge.simpson.net> <545A6894.7040506@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>,
	troy_tan@realsil.com.cn
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:64661 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbaKFLk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 06:40:28 -0500
In-Reply-To: <545A6894.7040506@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 04:12 PM, Larry Finger wrote:
> On 11/05/2014 03:16 AM, Mike Galbraith wrote:
>> On Wed, 2014-10-29 at 23:30 -0500, Larry Finger wrote:
>>> On 10/29/2014 06:28 PM, Murilo Opsfelder Araujo wrote:
>>>> This is a complement of commit 08054200117a95afc14c3d2ed3a38bf4e345bf78
>>>> "rtlwifi: Add check for get_btc_status callback".
>>>>
>>>> With this patch, next-20141029 at least does not panic with rtl8192se
>>>> device.
>>>>
>>>
>>> This patch is OK, but as noted it is not complete.
>>>
>>> I have patches to fix all the kernel panics for rtl8192se AND
>>> rtl8192ce. There
>>> are missing parts, but I would prefer submitting mine, which would
>>> conflict with
>>> this one. For that reason, NACK for this one, and please apply the
>>> set I am
>>> submitting now.
>>
>> It's all in there now, but my RTL8191SEvB is still dead.  Squabbling
>> with it isn't going all that well either.
>>
>> As soon as 38506ece rtlwifi: rtl_pci: Start modification for new drivers
>> is applied, explosions appear.  Subsequently applying...
>>
>> 08054200 rtlwifi: Add check for get_btc_status callback
>> c0386f15 rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for
>> missing get_btc_status
>> 50147969 rtlwifi: rtl8192se: Fix duplicate calls to
>> ieee80211_register_hw()
>> 30c5ccc6 rtlwifi: rtl8192se: Add missing section to read descriptor
>> setting
>> 75a916e1 rtlwifi: rtl8192se: Fix firmware loading
>>
>> ...fixes that mess up, but leaves the interface dead in the same manner
>> as if nothing has been reverted.  So it _seems_ the bustage lurks in
>> 38506ece somewhere.  Too bad it's non-dinky, and written in wifi-ese :)
> 
> Yes, I am aware that rtl8192se is failing, and now that I am back from
> vacation, I am working on the problem. If you want to use the driver
> with kernel 3.18, clone the repo at
> http://github.com/lwfinger/rtlwifi_new.git and build and install either
> the master or kernel_version branches. Both work.
> 
> I am in the process of trying to find what the crucial difference is
> between that repo and the kernel version.
> 
> Larry
> 
> 
I'm sending to everyone so others can jump in as well.

Here are the steps I've followed.

Installed and booted my kernel:

$ sudo dpkg -i linux-image-3.18.0-rc3-next-20141105-panda_3.18.0-rc3-next-20141105-panda-1_amd64.deb linux-headers-3.18.0-rc3-next-20141105-panda_3.18.0-rc3-next-20141105-panda-1_amd64.deb

Built modules from Larry's github repository.

$ cd rtlwifi_new
$ make
$ sudo make install

$ sudo modprobe -rv rtl8192se
rmmod rtl8192se
rmmod rtl_pci
rmmod rtlwifi
rmmod mac80211
rmmod cfg80211

The module does not load:

$ sudo modprobe -v rtl8192se
insmod /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/net/wireless/cfg80211.ko
insmod /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/net/mac80211/mac80211.ko
insmod /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/drivers/net/wireless/rtlwifi/rtlwifi.ko
insmod /lib/modules/3.18.0-rc3-next-20141105-panda/kernel/drivers/net/wireless/rtlwifi/rtl_pci.ko
insmod /lib/modules/3.18.0-rc3-next-20141105-panda/extra/rtl8192se.ko
ERROR: could not insert 'rtl8192se': Invalid argument

And /var/log/messages showed:

Nov  5 22:28:01 laptop kernel: [  301.276806] rtl8192se: disagrees about version of symbol rtl_process_phyinfo
Nov  5 22:28:01 laptop kernel: [  301.276812] rtl8192se: Unknown symbol rtl_process_phyinfo (err -22)
Nov  5 22:28:01 laptop kernel: [  301.276864] rtl8192se: disagrees about version of symbol rtl_get_tcb_desc
Nov  5 22:28:01 laptop kernel: [  301.276866] rtl8192se: Unknown symbol rtl_get_tcb_desc (err -22)

-- 
Murilo
