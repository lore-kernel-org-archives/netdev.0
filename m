From: David Miller <davem@davemloft.net>
Subject: Re: [patch 24/28] netconsole: Introduce netconsole_netdev_notifier
Date: Fri, 10 Aug 2007 15:33:13 -0700 (PDT)
Message-ID: <20070810.153313.24202743.davem@davemloft.net>
References: <200708102112.l7ALC7Vf009451@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satyam@infradead.org,
	k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753139AbXHJWdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:33:13 -0400
In-Reply-To: <200708102112.l7ALC7Vf009451@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:12:06 -0700

> From: Satyam Sharma <satyam@infradead.org>
> 
> Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.
> 
> To update fields of underlying netpoll structure at runtime on corresponding
> NETDEV_CHANGEADDR or NETDEV_CHANGENAME notifications.
> 
> ioctl(SIOCSIFHWADDR or SIOCSIFNAME) could be used to change the hardware/MAC
> address or name of the local interface that our netpoll is attached to. 
> Whenever this happens, netdev notifier chain is called out with the
> NETDEV_CHANGEADDR or NETDEV_CHANGENAME event message.  We respond to that and
> update the local_mac or dev_name field of the struct netpoll.  This makes
> sense anyway, but is especially required for dynamic netconsole because the
> netpoll structure's internal members become user visible files when either
> sysfs or configfs are used.  So this helps us to keep up with the MAC
> address/name changes and keep values in struct netpoll uptodate.
> 
> [ Note that ioctl(SIOCSIFADDR) to change IP address of interface at
>   runtime is not handled (to update local_ip of netpoll) on purpose --
>   some setups may set the local_ip to a private address, not necessary
>   the actual IP address of the sender host, as presently allowed. ]
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
> Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
