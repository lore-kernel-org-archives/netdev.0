From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 5 Sep 2002 13:47:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <288F9BF66CD9D5118DF400508B68C4460283E5BC@orsmsx113.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Troy Wilson'" <tcw@tempest.prismnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Troy Wilson wrote:
>   I've got some early SPECWeb [*] results with 2.5.33 and TSO 
> on e1000.  I get 2906 simultaneous connections, 99.2% 
> conforming (i.e. faster than the 320 kbps cutoff), at 0% idle 
> with TSO on.  For comparison, with 2.5.25, I 
> got 2656, and with 2.5.29 I got 2662, (both 99+% conformance 
> and 0% idle) so TSO and 2.5.33 look like a Big Win.

A 10% bump is good.  Thanks for running the numbers.
  
>   I'm having trouble testing with TSO off (I changed the 
> #define NETIF_F_TSO to "0" in include/linux/netdevice.h to 
> turn it off).  I am getting errors.

Sorry, I should have made a CONFIG switch.  Just hack the driver for now to
turn it off:

--- linux-2.5/drivers/net/e1000/e1000_main.c	Fri Aug 30 19:26:57 2002
+++ linux-2.5-no_tso/drivers/net/e1000/e1000_main.c	Thu Sep  5 13:38:44
2002
@@ -428,9 +428,11 @@ e1000_probe(struct pci_dev *pdev,
 	}
 
 #ifdef NETIF_F_TSO
+#if 0
 	if(adapter->hw.mac_type >= e1000_82544)
 		netdev->features |= NETIF_F_TSO;
 #endif
+#endif
  
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;

-scott
