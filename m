From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] network hotplug via class_device/kobject
Date: 15 Jun 2003 21:32:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <m31xxvgmqx.fsf@defiant.pm.waw.pl>
References: <20030613164119.15209934.shemminger@osdl.org>
	<20030615.005055.55726223.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, greg@kroah.com, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030615.005055.55726223.davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

>    Paranoid about some driver doing something like:
>    	rtnl_lock(); register_netdevice(); unregister_netdevice();
> rtnl_unlock() BOOM
> 
> These sorts of turds exist at least in two places:
> 
> 1) drivers/net/wan/comx.c
> 2) drivers/net/wan/hdlc_fr.c
> 
> But it is pretty clear that these two drivers have been
> tried by nobody in recent years.  They both call into
> {un,}register_netdevice without the RTNL semaphore held.

Not sure about 1), but 2) calls (un)register_netdevice() with rtnl_lock,
from ioctl.
-- 
Krzysztof Halasa
Network Administrator
