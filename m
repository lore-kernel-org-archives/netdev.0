From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/4] r8152: fix scheduling napi
Date: Wed, 25 Jan 2017 22:47:49 -0500 (EST)
Message-ID: <20170125.224749.986545008082919012.davem@davemloft.net>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
        <1394712342-15778-247-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-247-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 26 Jan 2017 09:38:30 +0800

> v3:
> simply the argument for patch #3. Replace &tp->napi with napi.
> 
> v2:
> Add smp_mb__after_atomic() for patch #1.
> 
> v1:
> Scheduling the napi during the following periods would let it be ignored.
> And the events wouldn't be handled until next napi_schedule() is called.
> 
> 1. after napi_disable and before napi_enable().
> 2. after all actions of napi function is completed and before calling
>    napi_complete().
> 
> If no next napi_schedule() is called, tx or rx would stop working.
> 
> In order to avoid these situations, the followings solutions are applied.
> 
> 1. prevent start_xmit() from calling napi_schedule() during runtime suspend
>    or after napi_disable().
> 2. re-schedule the napi for tx if it is necessary.
> 3. check if any rx is finished or not after napi_enable().

Series applied.
