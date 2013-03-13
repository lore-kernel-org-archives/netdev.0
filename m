From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v3] netxen: write IP address to firmware when
 using bonding
Date: Wed, 13 Mar 2013 11:34:23 +0100
Message-ID: <5140562F.8080009@redhat.com>
References: <1363092541-12391-1-git-send-email-nikolay@redhat.com> <20130313.044244.2078533144108853623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	agospoda@redhat.com, sony.chacko@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9135 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027Ab3CMKec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 06:34:32 -0400
In-Reply-To: <20130313.044244.2078533144108853623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/03/13 09:42, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> Date: Tue, 12 Mar 2013 13:49:01 +0100
> 
>> This patch allows LRO aggregation on bonded devices that contain an
>> NX3031 device. It also adds a for_each_netdev_in_bond_rcu(bond, slave)
>> macro which executes for each slave that has bond as master.
> 
> The new logic looks like it will configure the IPs for bonding
> but not for VLANs, is that intentional?
The case bond -> vlan -> netxen was intentionally dropped as it leads to
many new issues, if that is what you are referring to. The case vlan ->
netxen still works, since the address of orig_dev is unconditionally
programmed if the original dev is a netxen. The problem was with a bond
acting on a vlan which is configured on a netxen because we would have
to keep track of which bonding master the programmed addresses belong to.
