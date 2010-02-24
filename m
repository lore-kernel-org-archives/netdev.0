From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: octeon dev_addrs list usage
Date: Wed, 24 Feb 2010 10:10:15 -0800
Message-ID: <4B856B87.9030507@caviumnetworks.com>
References: <20100223204151.GG2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:7748 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756794Ab0BXSK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 13:10:57 -0500
In-Reply-To: <20100223204151.GG2673@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2010 12:41 PM, Jiri Pirko wrote:
> Hello David.
>
> Lookin at octeon driver, drivers/net/octeon/octeon_mgmt.c,
> octeon_mgmt_set_rx_filtering function and following code:
>
> 503         if (cam_mode == 1) {
> 504                 /* Add primary address. */
> 505                 octeon_mgmt_cam_state_add(&cam_state, netdev->dev_addr);
> 506                 list_for_each(pos,&netdev->dev_addrs.list) {
> 507                         struct netdev_hw_addr *hw_addr;
> 508                         hw_addr = list_entry(pos, struct netdev_hw_addr, list);
> 509                         octeon_mgmt_cam_state_add(&cam_state, hw_addr->addr);
> 510                         list = list->next;
> 511                 }
> 512         }
>
> besides netdev->dev_addr is first entry in netdev->dev_addrs.list and

Ok.

> "list = list->next;" makes no sense here (I posted a patch correcting
> these earlier),

Right, that does look wrong.


> are you sure you are traversing the right list? This list is
> currently not filled in anywhere (besides ixgbe driver). Don't you want
> to traverse through unicast_list instead? Maybe I'm missing something...
>

You are likely right. I will revisit this code, but it could be a couple 
of days.

Thanks for looking at it,
David Daney


