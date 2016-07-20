From: Fengguang Wu <lkp@intel.com>
Subject: Re: [kbuild-all] [PATCH v17 net-next 1/1] hv_sock: introduce Hyper-V
 Sockets
Date: Wed, 20 Jul 2016 11:06:19 +0800
Message-ID: <20160720030619.GA26466@wfg-t540p.sh.intel.com>
References: <CO2PR03MB2182D860B8B31579770E3798BF330@CO2PR03MB2182.namprd03.prod.outlook.com>
 <201607200149.0W6994tY%fengguang.wu@intel.com>
 <CO2PR03MB218232E102F17C0E8B3B7764BF080@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160719.195253.2126109938824378508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: decui@microsoft.com, mkubecek@suse.cz, olaf@aepfle.de,
	gregkh@linuxfoundation.org, jasowang@redhat.com,
	dave.scott@docker.com, linux-kernel@vger.kernel.org,
	joe@perches.com, rolf.neugebauer@docker.com, kbuild-all@01.org,
	netdev@vger.kernel.org, apw@canonical.com,
	devel@linuxdriverproject.org, vkuznets@redhat.com,
	kys@microsoft.com, cavery@redhat.com, haiyangz@microsoft.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160719.195253.2126109938824378508.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2016 at 07:52:53PM -0700, David Miller wrote:
>From: Dexuan Cui <decui@microsoft.com>
>Date: Wed, 20 Jul 2016 01:48:18 +0000
>
>>> From: kbuild test robot [mailto:lkp@intel.com]
>>> Sent: Wednesday, July 20, 2016 1:10
>>>
>>> Hi,
>>>
>>> [auto build test WARNING on net-next/master]
>>>
>>> url:    https://github.com/0day-ci/linux/commits/Dexuan-Cui/introduce-
>>> Hyper-V-VM-Sockets-hv_sock/20160715-223433
>>> config: x86_64-randconfig-a0-07191719 (attached as .config)
>>> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
>>> reproduce:
>>>         # save the attached .config to linux build tree
>>>         make ARCH=x86_64
>>>
>>> All warnings (new ones prefixed by >>):
>>>
>>>    net/hv_sock/af_hvsock.c: In function 'hvsock_open_connection':
>>>    net/hv_sock/af_hvsock.c:693: warning: 'hvsk' may be used uninitialized in
>>> this function
>>>    net/hv_sock/af_hvsock.c:693: warning: 'new_hvsk' may be used
>>> uninitialized in this function
>>>    net/hv_sock/af_hvsock.c:697: warning: 'new_sk' may be used uninitialized
>>> in this function
>>>    net/hv_sock/af_hvsock.c: In function 'hvsock_sendmsg_wait':
>>>    net/hv_sock/af_hvsock.c:1053: warning: 'ret' may be used uninitialized in
>>> this function
>>> >> net/hv_sock/af_hvsock.o: warning: objtool: hvsock_on_channel_cb()+0x1d:
>>> function has unreachable instruction
>>
>> These warnings are all false alarms.
>
>But you still have to quiet them.

Agreed.

However the last warning

        objtool: hvsock_on_channel_cb()+0x1d: function has unreachable instruction

is my fault -- it turns out to be a problem with old gcc-4.4 and
gcc-4.6 which we enabled 2 days ago. I just disabled reporting this
odd warning because it complaints on ~10000 functions all over the
place, which can only be sanely fixed in the toolchain.

Thanks,
Fengguang
