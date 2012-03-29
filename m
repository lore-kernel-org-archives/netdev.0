From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: emit event when bonding changes MAC
Date: Thu, 29 Mar 2012 18:12:20 -0400 (EDT)
Message-ID: <20120329.181220.1671496234086192108.davem@davemloft.net>
References: <5e96194e81e0540ebd35cf0bb1b407aa15a20613.1332910907.git.wpan@redhat.com>
	<15892.1333041584@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wpan@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	lwang@redhat.com, linux-kernel@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15892.1333041584@death.nxdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 29 Mar 2012 10:19:44 -0700

> Weiping Pan <wpan@redhat.com> wrote:
> 
>>When a bonding device is configured with fail_over_mac=active,
>>we expect to see the MAC address of the new active slave as the source MAC
>>address after failover. But we see that the source MAC address is the MAC
>>address of previous active slave.
>>
>>Emit NETDEV_CHANGEADDR event when bonding changes its MAC address, in order
>>to let arp_netdev_event flush neighbour cache and route cache.
>>
>>How to reproduce this bug ?
>>
>>                       -----------hostB----------------
>>hostA ----- switch ---|-- eth0--bond0(192.168.100.2/24)|
>>(192.168.100.1/24  \--|-- eth1-/                       |
>>                       --------------------------------
>>
>>1 on hostB,
>>modprobe bonding mode=1 miimon=500 fail_over_mac=active downdelay=1000
>>num_grat_arp=1
>>ifconfig bond0 192.168.100.2/24 up
>>ifenslave bond0 eth0
>>ifenslave bond0 eth1
>>
>>then eth0 is the active slave, and MAC of bond0 is MAC of eth0.
>>
>>2 on hostA, ping 192.168.100.2
>>
>>3 on hostB,
>>tcpdump -i bond0 -p icmp -XXX
>>you will see bond0 uses MAC of eth0 as source MAC in icmp reply.
>>
>>4 on hostB,
>>ifconfig eth0 down
>>tcpdump -i bond0 -p icmp -XXX (just keep it running in step 3)
>>you will see first bond0 uses MAC of eth1 as source MAC in icmp
>>reply, then it will use MAC of eth0 as source MAC.
>>
>>Signed-off-by: Weiping Pan <wpan@redhat.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks everyone.
