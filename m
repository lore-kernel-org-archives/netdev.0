From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] Don't use destructor in bridge
Date: Fri, 09 May 2003 21:34:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509.213453.23041916.davem@redhat.com>
References: <20030509131515.6c3d34ca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030509131515.6c3d34ca.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Fri, 9 May 2003 13:15:15 -0700

   This patch changes the Ethernet bridge back to the original way
   without having a destructor function.  This is done so the route
   cache side effect code doesn't hold onto a reference to the device.

If destructors are racy and do not work, we don't fix this
by removing destructors from netdevice drivers.

I do not accept this patch.  We must fix the core problem.

And your patch even creates a new problem.  Remember how Alexey
mentioned that that spinning/sleeping loop in unregister_netdevice()
is deadlock prone and basically illegal itself.
