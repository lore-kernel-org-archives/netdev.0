From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] tulip/xircom initialization bug
Date: Wed, 04 Jun 2003 21:17:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604.211750.28820261.davem@redhat.com>
References: <20030604112136.7b8e2cf4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030604112136.7b8e2cf4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Wed, 4 Jun 2003 11:21:36 -0700

   By inspection of device initialization code, this driver
   unregister's the net device in the error path even though the
   register_netdevice never succeeded.
   
This is fully legal, unregister_netdevice() checks for existence of
the netdev in the device list and if not found it returns an error.

This severely simplifies error path handling while we convert all
these drivers away from init_etherdev().
