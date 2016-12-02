From: David Miller <davem@davemloft.net>
Subject: Re: [PATH net v2] cdc_ether: Fix handling connection notification
Date: Fri, 02 Dec 2016 13:40:42 -0500 (EST)
Message-ID: <20161202.134042.35902054506958012.davem@davemloft.net>
References: <20161201132317.32324-1-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: oliver@neukum.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kristian.evensen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201132317.32324-1-kristian.evensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kristian Evensen <kristian.evensen@gmail.com>
Date: Thu,  1 Dec 2016 14:23:17 +0100

> Commit bfe9b9d2df66 ("cdc_ether: Improve ZTE MF823/831/910 handling")
> introduced a work-around in usbnet_cdc_status() for devices that exported
> cdc carrier on twice on connect. Before the commit, this behavior caused
> the link state to be incorrect. It was assumed that all CDC Ethernet
> devices would either export this behavior, or send one off and then one on
> notification (which seems to be the default behavior).
> 
> Unfortunately, it turns out multiple devices sends a connection
> notification multiple times per second (via an interrupt), even when
> connection state does not change. This has been observed with several
> different USB LAN dongles (at least), for example 13b1:0041 (Linksys).
> After bfe9b9d2df66, the link state has been set as down and then up for
> each notification. This has caused a flood of Netlink NEWLINK messages and
> syslog to be flooded with messages similar to:
> 
> cdc_ether 2-1:2.0 eth1: kevent 12 may have been dropped
> 
> This commit fixes the behavior by reverting usbnet_cdc_status() to how it
> was before bfe9b9d2df66. The work-around has been moved to a separate
> status-function which is only called when a known, affect device is
> detected.
> 
> v1->v2:
> 
> * Do not open-code netif_carrier_ok() (thanks Henning Schild).
> * Call netif_carrier_off() instead of usb_link_change(). This prevents
> calling schedule_work() twice without giving the work queue a chance to be
> processed (thanks Bjørn Mork).
> 
> Fixes: bfe9b9d2df66 ("cdc_ether: Improve ZTE MF823/831/910 handling")
> Reported-by: Henning Schild <henning.schild@siemens.com>
> Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>

Applied and queued up for -stable, thanks.
