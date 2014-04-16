From: "Li, ZhenHua" <zhen-hual@hp.com>
Subject: Re: [PATCH 1/1] driver/net: add missing rtnl lock/unlock for benet
Date: Wed, 16 Apr 2014 14:30:49 +0800
Message-ID: <534E2399.5030801@hp.com>
References: <1397544352-28841-1-git-send-email-zhen-hual@hp.com> <20140415.150950.2105729446204659132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140415.150950.2105729446204659132.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

I think you are right. I checked other NIC drivers, found some of them 
call rtnl_lock and rtnl_unlock around netif_device_detach and attach 
functions, while some drivers did not.

I will create a new patch in generic way to fix this.

Regards
ZhenHua
On 04/16/2014 03:09 AM, David Miller wrote:
> From: "Li, Zhen-Hua" <zhen-hual@hp.com>
> Date: Tue, 15 Apr 2014 14:45:52 +0800
>
>> From: "Li, Zhen-Hua" <zhen-hual@hp.com>
>>
>> In benet driver, netif_device_detach and netif_device_attach should be
>> called between rtnl_lock and rtnl_unlock.
>>
>> Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>
>
> This absolutely does not look like a driver specific issue, therefore
> I do not want you to make such locking context adjustments only in
> your driver.
>
> Do it somewhere generic so that every driver gets the fix, not just
> your driver.
>
