From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.6 patch] /net/ax25/: some cleanups
Date: Tue, 28 Dec 2004 21:54:06 +0000
Message-ID: <1104270846.26109.3.camel@localhost.localdomain>
References: <20041212211339.GX22324@stusta.de>
	 <20041227185151.2a7ceb71.davem@davemloft.net>
	 <1104237408.20944.70.camel@localhost.localdomain>
	 <20041228100507.7b374b5e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
        netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041228100507.7b374b5e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Maw, 2004-12-28 at 18:05, David S. Miller wrote:
> Send a patch to netdev and CC: me to fix this as is standard
> procedure for getting changes into the networking.  :-)

Attached - revert to 2.6.9 behaviour.

I suspect given that someone made the change for a reason that there
should probably be a sysctl to switch between AX.25 (as 2.6.9) and "kind
of routed AX.25-ish" (as 2.6.10).

--- ../linux.vanilla-2.6.10/net/ax25/af_ax25.c	2004-12-25 21:15:46.000000000 +0000
+++ net/ax25/af_ax25.c	2004-12-26 22:07:44.000000000 +0000
@@ -207,8 +207,16 @@
 			continue;
 		if (s->ax25_dev == NULL)
 			continue;
-		if (ax25cmp(&s->source_addr, src_addr) == 0 &&
-		    ax25cmp(&s->dest_addr, dest_addr) == 0) {
+		if (ax25cmp(&s->source_addr, src_addr) == 0 && ax25cmp(&s->dest_addr, dest_addr) == 0 && s->ax25_dev->dev == dev) {
+			if (digi != NULL && digi->ndigi != 0) {
+				if (s->digipeat == NULL)
+					continue;
+				if (ax25digicmp(s->digipeat, digi) != 0)
+					continue;
+			} else {
+				if (s->digipeat != NULL && s->digipeat->ndigi != 0)
+					continue;
+			}
 			ax25_cb_hold(s);
 			spin_unlock_bh(&ax25_list_lock);
 
