From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] hp100 -- fixes for new probing.
Date: Tue, 24 Feb 2004 17:07:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040224170700.11adc3cc@dell_ss3.pdx.osdl.net>
References: <20040223094925.344bc73d@dell_ss3.pdx.osdl.net>
	<20040224233602.36835.qmail@web14004.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Cacophonix <cacophonix@yahoo.com>
In-Reply-To: <20040224233602.36835.qmail@web14004.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Does fix the problem?  it checks for card before proceeding in hp100_isa_probe

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	Tue Feb 24 17:05:54 2004
+++ b/drivers/net/hp100.c	Tue Feb 24 17:05:54 2004
@@ -333,6 +333,11 @@
 
 	if (!request_region(addr, HP100_REGION_SIZE, "hp100"))
 		goto err;
+	
+	if (hp100_inw(HW_ID) != HP100_HW_ID_CASCADE) {
+		release_region(addr, HP100_REGION_SIZE);
+		goto err;
+	}
 
 	sig = hp100_read_id(addr);
 	release_region(addr, HP100_REGION_SIZE);
