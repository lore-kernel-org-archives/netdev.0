From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug, -git] ERROR: "ebt_unregister_table"	[net/bridge/netfilter/ebtable_nat.ko]
 undefined
Date: Tue, 14 Oct 2008 13:00:09 +0200
Message-ID: <48F47BB9.9090902@trash.net>
References: <20080821221943.GO31136@x200.localdomain> <20081013070347.GA3813@elte.hu> <20081013070940.GA6340@elte.hu> <20081013073501.GB4254@x200.localdomain> <20081014103005.GA19420@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080305030308060309020303"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.et,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081014103005.GA19420@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080305030308060309020303
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Ingo Molnar wrote:
> i think you misunderstood my report. This is about latest upstream -git 
> being broken:
> 
> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_filter.ko] undefined!
> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> 
> i posted to this thread because i wanted to find a relevant context. 
> (but probably is not)
> 
> Anyway, i started a new thread for this.
> 
> the dependencies there look pretty complex so i did not find a quick fix 
> - but i can test patches.

This appears to be caused by Jan's Kconfig changes to use menuconfig,
which lost a dependency on BRIDGE:

-menu "Bridge: Netfilter Configuration"
-       depends on BRIDGE && BRIDGE_NETFILTER
-
-config BRIDGE_NF_EBTABLES
+menuconfig BRIDGE_NF_EBTABLES
         tristate "Ethernet Bridge tables (ebtables) support"
         select NETFILTER_XTABLES
         help
           ebtables is a general, extensible frame/packet identification
           framework. Say 'Y' or 'M' here if you want to do Ethernet
           filtering/NAT/brouting on the Ethernet bridge.

Does this patch fix it?

--------------080305030308060309020303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index 366d3e9..ba6f73e 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -4,6 +4,7 @@
 
 menuconfig BRIDGE_NF_EBTABLES
 	tristate "Ethernet Bridge tables (ebtables) support"
+	depends on BRIDGE && BRIDGE_NETFILTER
 	select NETFILTER_XTABLES
 	help
 	  ebtables is a general, extensible frame/packet identification

--------------080305030308060309020303--
