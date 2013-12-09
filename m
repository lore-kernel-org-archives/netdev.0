From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/1] drivers: net : cpsw: Use netdev_name while requesting
 irq
Date: Mon, 9 Dec 2013 14:59:05 +0530
Message-ID: <52A58D61.9060404@ti.com>
References: <1386313107-8597-1-git-send-email-mugunthanvnm@ti.com> <20131206.154640.2274056773488827363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<george.cherian@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20131206.154640.2274056773488827363.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 07 December 2013 02:16 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Fri, 6 Dec 2013 12:28:27 +0530
>
>> From: George Cherian <george.cherian@ti.com>
>>
>> Use netdev_name while requesting irq so that eth* name is shown
>> in /proc/interrupts. Previously it was showing device name as (null)
>> for cpsw interrupts. For using netdev_name register_netdev and then
>> call devm_request_irq.
>>
>> Signed-off-by: George Cherian <george.cherian@ti.com>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> Why is it showing "(null)" as the name, is dev_name() not working
> properly for this device?
>
> The only change you are making is passing netdev_name() instead
> of dev_name().  dev_name() giving NULL doesn't make much sense
> to me.
priv->dev is a network device which is registered to network stack after
request interrupt, so dev name is null, with this patch request
interrupt is moved below after registering the network device with the
network

Initial driver was using DT node name for the interrupts, but with the
devm changes by Daniel Mack in commit 50a5fb068 it was changed to ndev
name which introduced this issue.

Regards
Mugunthan V N
