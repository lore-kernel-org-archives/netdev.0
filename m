From: Andy Fleming <afleming@freescale.com>
Subject: PATCH: Some random ethtool fixes
Date: Tue, 8 Mar 2005 17:11:10 -0600
Message-ID: <e0f0506f97b60f97d376756c72e88c6e@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-1-1019768010
Cc: Kumar Gala <kumar.gala@freescale.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Apple-Mail-1-1019768010
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed

The patch I sent out earlier had some other changes which were just 
little bug fixes, and I have distilled those into this patch.  This 
patch applies on ethtool.c (from the application).  It fixes these 
problems:

* Allows ethtool -s to set the negotiated speed to 1000 (full/half)
* Causes ethtool -s ethN autoneg on to enable gigabit speeds as well as 
the others
* Fixes a spelling error where external was spelled "externel"


--Apple-Mail-1-1019768010
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="ethtool_20050308.patch"
Content-Disposition: attachment;
	filename=ethtool_20050308.patch

Index: ethtool.c
===================================================================
RCS file: /cvsroot/gkernel/ethtool/ethtool.c,v
retrieving revision 1.50
diff -u -r1.50 ethtool.c
--- ethtool.c   2 Jul 2004 15:35:09 -0000       1.50
+++ ethtool.c   8 Mar 2005 23:01:51 -0000
@@ -681,13 +681,21 @@
                else if (speed_wanted == SPEED_100 &&
                         duplex_wanted == DUPLEX_FULL)
                        advertising_wanted = ADVERTISED_100baseT_Full;
-               else
+               else if (speed_wanted == SPEED_1000 &&
+                        duplex_wanted == DUPLEX_HALF)
+                       advertising_wanted = ADVERTISED_1000baseT_Half;
+               else if (speed_wanted == SPEED_1000 &&
+                        duplex_wanted == DUPLEX_FULL)
+                       advertising_wanted = ADVERTISED_1000baseT_Full;
+               else {
                        /* auto negotiate without forcing */
                        advertising_wanted = ADVERTISED_100baseT_Full |
                                ADVERTISED_100baseT_Half |
                                ADVERTISED_10baseT_Full |
-                               ADVERTISED_100baseT_Half;
-
+                               ADVERTISED_10baseT_Half |
+                               ADVERTISED_1000baseT_Half |
+                               ADVERTISED_1000baseT_Full;
+               }
        }
 
        if (devname == NULL) {
@@ -857,7 +865,7 @@
                fprintf(stdout, "internal\n");
                break;
        case XCVR_EXTERNAL:
-               fprintf(stdout, "externel\n");
+               fprintf(stdout, "external\n");
                break;
        default:
                fprintf(stdout, "Unknown!\n");

--Apple-Mail-1-1019768010--
