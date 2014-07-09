From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] sunvnet: call unregister_netdev() exactly once
 per device
Date: Wed, 09 Jul 2014 07:27:26 -0400
Message-ID: <53BD271E.6030901@oracle.com>
References: <20140708161827.GO19954@sowmini.varadhan@oracle.com> <20140708.204218.141082766724192890.davem@davemloft.net>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.kleikamp@oracle.com,
	dan.carpenter@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37058 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbaGIL1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 07:27:34 -0400
In-Reply-To: <20140708.204218.141082766724192890.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2014 11:42 PM, David Miller wrote:

>
> This is definitely not the right fix, you're just removing a symptom
> of a much larger problem.
>
> And that problem is that nothing cleans up the objects created by
> vnet_new(), they are completely leaked.

the bug(s) in modprobe -r is one manifestation of the problem
and should certainly be fixed, I can look into the suggestions
you have below.

But this is actually a bit worse. Whenever a node goes
away, it triggers a vio_port_remove() on all the peering nodes,
and blows away their networking. IOW this can happen without
involving vnet_exit() at all. Thus it might be necessary
for vio_port_remove() itself to check if its the last port
before doing the unregister?

BTW, for some odd reason I did not see my original patch submission
show up in the list. I'm not sure why.

>
> vnet_exit(), after doing the vio_unregister_driver(), should call a
> helper function that iterates over vnet_list and cleans up those
> objects.
>
> That's where the unregister_netdevice() belongs, not in vnet_port_remove().
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
