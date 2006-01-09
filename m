From: Dan Williams <dcbw@redhat.com>
Subject: [patch] ipw2100: support WEXT-18 enc_capa v2
Date: Mon, 09 Jan 2006 10:39:40 -0500
Message-ID: <1136821181.7941.9.camel@dhcp83-115.boston.redhat.com>
References: <1136820457.7941.4.camel@dhcp83-115.boston.redhat.com>
	 <43C282A5.6010609@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, netdev@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net
Return-path: <ipw2100-devel-admin@lists.sourceforge.net>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <43C282A5.6010609@pobox.com>
Sender: ipw2100-devel-admin@lists.sourceforge.net
Errors-To: ipw2100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:ipw2100-devel@lists.sourceforge.net>
List-Help: <mailto:ipw2100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw2100-devel>
List-Id: netdev.vger.kernel.org

Hi,

This patch allows ipw2100 driver to advertise the WPA-related encryption
options that it does really support.  It's necessary to work correctly
with NetworkManager and other programs that actually check driver & card
capabilities.

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- ipw2100.c.nowpa	2006-01-08 14:04:00.000000000 -0500
+++ ipw2100.c	2006-01-08 15:47:37.000000000 -0500
@@ -7236,7 +7236,7 @@
 
 	/* Set the Wireless Extension versions */
 	range->we_version_compiled = WIRELESS_EXT;
-	range->we_version_source = 16;
+	range->we_version_source = 18;
 
 //      range->retry_capa;      /* What retry options are supported */
 //      range->retry_flags;     /* How to decode max/min retry limit */
@@ -7262,6 +7262,9 @@
 	}
 	range->num_frequency = val;
 
+	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
+		IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
+
 	IPW_DEBUG_WX("GET Range\n");
 
 	return 0;




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
