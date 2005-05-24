From: Jiri Benc <jbenc@suse.cz>
Subject: [3/5] netdev: HH_DATA_OFF bugfix
Date: Tue, 24 May 2005 15:12:04 +0200
Message-ID: <20050524151204.554f73cb@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, jgarzik@pobox.com, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When the hardware header size is a multiple of HH_DATA_MOD, HH_DATA_OFF()
incorrectly returns HH_DATA_MOD (instead of 0).

Signed-off-by: Jiri Benc <jbenc@suse.cz>

--- linux/include/linux/netdevice.h
+++ work/include/linux/netdevice.h
@@ -204,7 +209,7 @@
 	/* cached hardware header; allow for machine alignment needs.        */
 #define HH_DATA_MOD	16
 #define HH_DATA_OFF(__len) \
-	(HH_DATA_MOD - ((__len) & (HH_DATA_MOD - 1)))
+	(HH_DATA_MOD - (((__len - 1) & (HH_DATA_MOD - 1)) + 1))
 #define HH_DATA_ALIGN(__len) \
 	(((__len)+(HH_DATA_MOD-1))&~(HH_DATA_MOD - 1))
 	unsigned long	hh_data[HH_DATA_ALIGN(LL_MAX_HEADER) / sizeof(long)];


--
Jiri Benc
SUSE Labs
