From: Greg KH <gregkh@suse.de>
Subject: [patch 05/11] tcp: BIC max increment too large
Date: Fri, 23 Dec 2005 14:27:36 -0800
Message-ID: <20051223222736.GF18252@kroah.com>
References: <20051109182205.294803000@press.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161086AbVLWWcN@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline; filename="tcp-bic-max-increment-too-large.patch"
In-Reply-To: <20051223222652.GA18252@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>

The max growth of BIC TCP is too large. Original code was based on
BIC 1.0 and the default there was 32. Later code (2.6.13) included
compensation for delayed acks, and should have reduced the default
value to 16; since normally TCP gets one ack for every two packets sent.

The current value of 32 makes BIC too aggressive and unfair to other
flows.

Submitted-by: Injong Rhee <rhee@eos.ncsu.edu>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv4/tcp_bic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.14.1.orig/net/ipv4/tcp_bic.c
+++ linux-2.6.14.1/net/ipv4/tcp_bic.c
@@ -27,7 +27,7 @@
 					  */
 
 static int fast_convergence = 1;
-static int max_increment = 32;
+static int max_increment = 16;
 static int low_window = 14;
 static int beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
 static int low_utilization_threshold = 153;

--
