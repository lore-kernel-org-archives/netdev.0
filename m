From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding:update speed/duplex for NETDEV_CHANGE
Date: Tue, 01 Nov 2011 17:53:23 -0400 (EDT)
Message-ID: <20111101.175323.1446639403785720039.davem@davemloft.net>
References: <14973.1320093129@death>
	<9765cb601d0b4330cf7775ec3cd6b9e1ea13c71e.1320117071.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org
To: wpan@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9765cb601d0b4330cf7775ec3cd6b9e1ea13c71e.1320117071.git.wpan@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weiping Pan <wpan@redhat.com>
Date: Tue,  1 Nov 2011 11:20:48 +0800

> Zheng Liang(lzheng@redhat.com) found a bug that if we config bonding with
> arp monitor, sometimes bonding driver cannot get the speed and duplex from
> its slaves, it will assume them to be 100Mb/sec and Full, please see
> /proc/net/bonding/bond0.
> But there is no such problem when uses miimon.
> 
> (Take igb for example)
> I find that the reason is that after dev_open() in bond_enslave(),
> bond_update_speed_duplex() will call igb_get_settings()
> , but in that function,
> it runs ethtool_cmd_speed_set(ecmd, -1); ecmd->duplex = -1;
> because igb get an error value of status.
> So even dev_open() is called, but the device is not really ready to get its
> settings.
> 
> Maybe it is safe for us to call igb_get_settings() only after
> this message shows up, that is "igb: p4p1 NIC Link is Up 1000 Mbps Full Duplex,
> Flow Control: RX".
> 
> So I prefer to update the speed and duplex for a slave when reseices
> NETDEV_CHANGE/NETDEV_UP event.
> 
> Changelog
> V2:
> 1 remove the "fake 100/Full" logic in bond_update_speed_duplex(),
>   set speed and duplex to -1 when it gets error value of speed and duplex.
> 2 delete the warning in bond_enslave() if bond_update_speed_duplex() returns
>   error.
> 3 make bond_info_show_slave() handle bad values of speed and duplex.
> 
> Signed-off-by: Weiping Pan <wpan@redhat.com>

Looks good, applied, thanks!
