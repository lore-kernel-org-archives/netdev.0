From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Tue, 8 Feb 2005 11:13:25 -0800
Message-ID: <20050208111325.45a8a106@dxpl.pdx.osdl.net>
References: <4203C32A.70402@linux.intel.com>
	<420843CF.7060303@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <420843CF.7060303@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A couple of observations:

1. You can get rid of the /proc interface altogether since now 
with sysfs module parameters can be made accessible via module_param

2. Include files need to be moved and factored better:
	include/linux/ieee80211.h for anything exposed to utilities and
	   general API related
	include/net/ieee80211.h for interfaces other drivers would use.
	drivers/net/wireless/iee80211/iee80211_xxx.h for stuff that
	   only gets used internally.

3. Remove the BIT() macro and instead show the shift.
   My preference would be to change to something like:

enum ieee80211_rate {
	IEEE80211_CCK_RATE_1MB_MASK	= 1<<0,
	IEEE80211_CCK_RATE_2MB_MASK	= 1<<1,
...

4. Don't put data in .h files like eap_types[]
   Maybe just move eap_get_type() to .c fle

5. Use C99 initializers for tags arrays like eap_types[]
 i.e static const char *eap_types[] = {
	[EAP_PACKET] = "EAP-Packet",
...
	
5. Move is_broadcast_addr and is_multicast_addr to etherdevice.h
   besides is_muliticast_addr(x) has extra uneeded test.

6. Don't put format type stuff in .h file MAC_FMT, MAC_ARG, etc...

7. Don't need () around simple integers in #define's
	#define IEEE80211_3ADDR_LEN (24)

8. Patch if_ether.h rather than stuff like:
 	#ifndef ETH_P_80211_RAW
 	#define ETH_P_80211_RAW (ETH_P_ECONET + 1)
	#endif

9. Isn't SNAP generic and not part of just wireless, LLC and other places
   like ATM have the similar stuff, maybe one set of routines and definitions?

10. Do we really need another set of statistics?  Already have ethtool, net_stats, wireless, ...?

11. Does ieee->scans need to be atomic?

12.  offset_in_page() shouldn't be here and is defined elsewhere.

The basic philosophy changes as this gets incorporated in mailine kernel.
You need to feel free to patch in several existing header files rather than
standing alone as required in an out of tree driver.
