From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] network hotplug via class_device/kobject
Date: Sun, 15 Jun 2003 00:50:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615.005055.55726223.davem@redhat.com>
References: <20030613164119.15209934.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030613164119.15209934.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Fri, 13 Jun 2003 16:41:19 -0700

   This patch changes network devices to run hotplug out of the
   kobject/class_device infrastructure rather than calling it from the
   network core. The code gets simpler and there is only one place for
   Greg to fix when he changes the API ;-)

I'll apply this patch, looks fine.
   
   Paranoid about some driver doing something like:
   	rtnl_lock(); register_netdevice(); unregister_netdevice(); rtnl_unlock() BOOM

These sorts of turds exist at least in two places:

1) drivers/net/wan/comx.c
2) drivers/net/wan/hdlc_fr.c

But it is pretty clear that these two drivers have been
tried by nobody in recent years.  They both call into
{un,}register_netdevice without the RTNL semaphore held.
