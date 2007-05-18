From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] netdevice ops
Date: Thu, 17 May 2007 21:23:16 -0700
Message-ID: <464D2A34.5000303@candelatech.com>
References: <20070517210737.17d88401@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:55344 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929AbXEREX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 00:23:57 -0400
In-Reply-To: <20070517210737.17d88401@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I want to take all the function pointers of 'struct net_device' and
> move them to 'struct net_device_ops'. This will save memory for the
> case of lots of devices, as well as reduce initialization code.
>
> Rough plan:
> 1. Introduce inline accessors so protocols don't dereference dev->XXX directly.
> 2. Fix protocols to use #1
> 3. Add ops field to net_device, and netdevice_register will fill in old values
>    in 'struct net_device'.
> 4...1300 Fix all network devices to use ops field
> 1301 Change accessors to use ops, get rid of old 'struct net_device' function pointers.
>
> It isn't rocket science just another code exercise. I'll patch bomb it into something
> like 2.6.23-mm first.
>
> This should really help the people who like to do 1000's of vlans etc.
>   
Vlan code uses several of the methods, so I'm not sure how it will save 
any memory unless
you will somehow have a variable sized net_device_ops structure, or 
maybe only move a
certain subset of methods into the ops struct?

Also, this will be a new chunk of memory to keep in cache and 
allocate/deallocate..wouldn't it be more efficient to
keep it local to the netdevice struct?

And there is an extra cost to dereference the point to the ops before 
calling methods?

Thanks,
Ben
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


