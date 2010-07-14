From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [4/5] Do not reset
 when the device is not opened
Date: Wed, 14 Jul 2010 14:07:18 -0700 (PDT)
Message-ID: <20100714.140718.115934967.davem@davemloft.net>
References: <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain>
	<alpine.LRH.2.00.1007070229030.5939@localhost.localdomain>
	<alpine.LRH.2.00.1007131749030.32055@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, ronghua@vmware.com, matthieu@vmware.com
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007131749030.32055@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Tue, 13 Jul 2010 17:49:52 -0700 (PDT)

> 
> Do not reset when the device is not opened
> 
> If a reset is scheduled, and the device goes thru close and open, it
> may happen that reset and open may run in parallel.
> The reset code now bails out if the device is not opened.
>  
> Signed-off-by: Ronghua Zang <ronghua@vmware.com>
> Signed-off-by: Matthieu Bucchianeri <matthieu@vmware.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

Testing IFF_UP is just making your race hole a little smaller but
it isn't fixing the problem.

In fact, there really isn't any legitimate reason for a driver
to test the IFF_UP state bit.  netif_running() is the correct
test, and asynchronous work queue things like resets should
synchronize with open/close using the RTNL lock so that your
test of netif_running() is a stable one.
