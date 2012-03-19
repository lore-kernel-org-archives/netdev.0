From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V4] bonding: send igmp report for its master
Date: Mon, 19 Mar 2012 18:06:27 -0400 (EDT)
Message-ID: <20120319.180627.188597318051406465.davem@davemloft.net>
References: <31016.1331869399@death.nxdomain>
	<07f6298b0c2dca06856e6dcdab7f684447b6f199.1332040061.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <07f6298b0c2dca06856e6dcdab7f684447b6f199.1332040061.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weiping Pan <panweiping3@gmail.com>
Date: Sun, 18 Mar 2012 11:23:27 +0800

> Liang Zheng(lzheng@redhat.com) found that in the following topo,
> bonding does not send igmp report when we trigger a fail-over of bonding.
> 
> eth0--
>       |-- bond0 -- br0
> eth1--
> 
> modprobe bonding mode=1 miimon=100 resend_igmp=10
> ifconfig bond0 up
> ifenslave bond0 eth0 eth1
> 
> brctl addbr br0
> ifconfig br0 192.168.100.2/24 up
> brctl addif br0 bond0
> 
> Add 192.168.100.2(br0) into a multicast group, like 224.10.10.10,
> then trigger a fali-over in bonding.
> You can see that parameter "resend_igmp" does not work.
> 
> The reason is that when we add br0 into a multicast group,
> it does not propagate multicast knowledge down to its ports.
> 
> If we choose to propagate multicast knowledge down to all ports for bridge,
> then we have to track every change that is done to bridge, and keep a backup
> for all ports. It is hard to track, I think.
> 
> Instead I choose to modify bonding to send igmp report for its master.
> 
> Changelog:
> V2: correct comments
> V3: move this check into bond_resend_igmp_join_requests()
> V4: only send igmp reports if bond is enslaved to a bridge
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Applied.
