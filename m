From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 22:10:35 +0100
Message-ID: <20041207211035.GA20286@quickstop.soohrt.org>
References: <20041206205305.GA11970@soohrt.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261895AbULGVKr@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041206205305.GA11970@soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Karsten Desler <kdesler@soohrt.org> wrote:
> Current packetload on eth0 (and reversed on eth1):
>   115kpps tx
>   135kpps rx

I totally forgot to mention: There are approximately 100k concurrent
flows.

>From dmesg:
IP: routing cache hash table of 16384 buckets, 128Kbytes

Maybe there is some contention on the rt_hash_table spinlocks?
Is the attached patch enough to increase the size?

- Karsten

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="rtcachesize.patch"

--- linux/net/ipv4/route.c~old	2004-12-07 21:55:22.000000000 +0100
+++ linux/net/ipv4/route.c	2004-12-07 21:55:32.000000000 +0100
@@ -2728,7 +2728,7 @@
 	if (!ipv4_dst_ops.kmem_cachep)
 		panic("IP: failed to allocate ip_dst_cache\n");
 
-	goal = num_physpages >> (26 - PAGE_SHIFT);
+	goal = num_physpages >> (23 - PAGE_SHIFT);
 	if (rhash_entries)
 		goal = (rhash_entries * sizeof(struct rt_hash_bucket)) >> PAGE_SHIFT;
 	for (order = 0; (1UL << order) < goal; order++)

--y0ulUmNC+osPPQO6--
