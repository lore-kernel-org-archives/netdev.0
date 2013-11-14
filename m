From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: ti/cpsw: do not crash on single-MAC machines
 during resume
Date: Thu, 14 Nov 2013 18:39:45 +0530
Message-ID: <5284CB99.2020707@ti.com>
References: <1384347180-3490-1-git-send-email-zonque@gmail.com> <5284C602.8000103@ti.com> <5284C87A.60404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35823 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509Ab3KNNJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 08:09:50 -0500
In-Reply-To: <5284C87A.60404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 14 November 2013 06:26 PM, Daniel Mack wrote:
> On 11/14/2013 01:45 PM, Mugunthan V N wrote:
>> On Wednesday 13 November 2013 06:23 PM, Daniel Mack wrote:
>>> To prevent Oopses, cpsw_suspend() should only soft-reset sliver 1
>>> on dual MAC enabled machines.
>>>
>>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>>> ---
>>>  drivers/net/ethernet/ti/cpsw.c | 5 ++++-
>>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>>> index edd3e79..702b063 100644
>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>> @@ -2173,8 +2173,11 @@ static int cpsw_suspend(struct device *dev)
>>>  
>>>  	if (netif_running(ndev))
>>>  		cpsw_ndo_stop(ndev);
>>> +
>>>  	soft_reset("sliver 0", &priv->slaves[0].sliver->soft_reset);
>>> -	soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);
>>> +	if (priv->data.dual_emac)
>>> +		soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);
>> Is this tested on a system with both ports in switch mode?
> Nope. I got an Ooops when I tried to suspend a machine that has only one
> slave configured in DTS.

But the changes above will fail with system with two ports and in switch
mode.

>
>> I don't think this will not work with both ports in switch mode.
> Why? Isn't priv->data.dual_emac in that case? The same condition is
> checked for in cpsw_remove().
In cpsw_remove that check is used to unregister the second network
interface registered for same device for port 2. Now I got the issue,
this has to be done via for_each_slave().

Regards
Mugunthan V N
