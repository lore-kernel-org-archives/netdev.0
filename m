From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Mon, 07 Feb 2005 18:49:13 -0800
Message-ID: <420828A9.7060306@osdl.org>
References: <4203C32A.70402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <4203C32A.70402@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> Attached is the patch against 2.6.11-rc3-mm1 that adds the ieee80211 
> subsystem used by the ipw2100 and ipw2200 projects.
> 
> I'll be sending out the patches for ipw2100-1.0.0 and ipw2200-1.0.0 that 
> use thist stack to the list on Monday.
> 
> In terms of what the stack currently does:
> 
> * HW independent -- it only knows about 802.11 data and structures
> * Performs an 802.3 <-> 802.11 transform for data Tx/Rx
> * Host based support for fragmentation, WEP, and WPA using the kernel's 
> crypto functions
> * Beacon and probe response collection and parsing
> * Default implementation of some of the WE handlers that can be managed 
> without hardware knowledge
> 
> We are working to merge in Dave Miller's p80211 code into the ieee80211 
> subsystem so that it hooks into the kernel as a true network layer as 
> opposed to a mutated offspring of ethernet.
> Once that is done, hopefully the skb to txb code can be reworked and 
> 802.11 fragments can be treated either as normal skbs, or skbs can be 
> modified to directly support them (ideally so that encrypted 802.11 
> frames in support of IP packets can be cached by the stack instead of 
> having to be re-encrypted on TCP retries)
> 
> Support for HW/FW crypto and fragmentation offload, in a HW independent 
> fashion, is also on the short-term list.
> 
> When you look through the patch you'll likely notice the #ifdef 
> NOTYET/#endif sequences surrounding portions of code from the hostap 
> project.  Portions of this subsystem were based on an earlier version of 
> the hostap project.  Those areas that weren't directly supported by the 
> ipw* projects weren't ported to be completely hardware independent 
> (since I don't have the hardware to test it), and so are still wrapped 
> in the ifdefs.  These sections mainly cover support for MASTER and WDS 
> modes.
> 
> Anyway, please let me know what you think.  Hopefully I built the patch 
> right...

James,
Can you post a patch that will build?  or did you just want
feedback on the current state of the patch?

Thanks,
-- 
~Randy


a.  in ieee80211/Makefile, there is nothing for ieee80211_module.o:

ieee80211-objs := \
	ieee80211_module.o \

b.  in wireless/Makefile, it needs to pull in ieee80211, e.g.:

--- Makefile~80211_netstack     2004-12-24 13:35:50.000000000 -0800
+++ Makefile    2005-02-07 18:37:49.000000000 -0800
@@ -2,6 +2,8 @@
  # Makefile for the Linux Wireless network device drivers.
  #

+obj-$(CONFIG_IEEE80211) += ieee80211/
+
  obj-$(CONFIG_STRIP) += strip.o
  obj-$(CONFIG_ARLAN) += arlan.o
