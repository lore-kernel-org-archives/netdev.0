From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: [9/14] Orinoco driver updates - update is_ethersnap()
Date: Thu, 24 Feb 2005 15:01:53 +1100
Message-ID: <20050224040153.GK32001@localhost.localdomain>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain> <20050224040024.GI32001@localhost.localdomain> <20050224040052.GJ32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20050224040052.GJ32001-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Make the is_ethersnap() function take a void * rather than a pointer
to the internal header structure.  This makes more logical sense and
reduces dependencies between different parts of the code.

Signed-off-by: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-02-24 14:50:48.426788064 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-02-24 14:50:50.125529816 +1100
@@ -966,15 +966,17 @@
 
 /* Does the frame have a SNAP header indicating it should be
  * de-encapsulated to Ethernet-II? */
-static inline int is_ethersnap(struct header_struct *hdr)
+static inline int is_ethersnap(void *_hdr)
 {
+	u8 *hdr = _hdr;
+
 	/* We de-encapsulate all packets which, a) have SNAP headers
 	 * (i.e. SSAP=DSAP=0xaa and CTRL=0x3 in the 802.2 LLC header
 	 * and where b) the OUI of the SNAP header is 00:00:00 or
 	 * 00:00:f8 - we need both because different APs appear to use
 	 * different OUIs for some reason */
-	return (memcmp(&hdr->dsap, &encaps_hdr, 5) == 0)
-		&& ( (hdr->oui[2] == 0x00) || (hdr->oui[2] == 0xf8) );
+	return (memcmp(hdr, &encaps_hdr, 5) == 0)
+		&& ( (hdr[5] == 0x00) || (hdr[5] == 0xf8) );
 }
 
 static inline void orinoco_spy_gather(struct net_device *dev, u_char *mac,

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
