From: Donald Becker <becker@scyld.com>
Subject: Re: PATCH: sundance #5 (variable per-interface MTU support)
Date: Thu, 19 Sep 2002 18:28:09 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209191821050.29420-100000@beohost.scyld.com>
References: <20020919210348.GC17492@orr.falooley.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, <netdev@oss.sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Richard Gooch <rgooch@ras.ucalgary.ca>,
   "Patrick R. McManus" <mcmanus@ducksong.com>, <edward_peng@dlink.com.tw>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20020919210348.GC17492@orr.falooley.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Sep 2002, Jason Lunz wrote:

> This is a straightforward merge of variable mtu from donald's driver.

-	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
+	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 36);

Errrmm, not quite right.

Try
	np->rx_buf_sz = (dev->mtu <= 1520 ? PKT_BUF_SZ : dev->mtu + 16);

The idea is that all ethernet-like drivers always allocate skbuffs of
the same size, PKT_BUF_SZ (1536=3*512), unless a jumbo MTU forces a
larger size. 

Specificially, using VLANs (+4 bytes on the frame size) on some interfaces
should not result in a mix of allocation sizes.  Most VLAN-like
encapsulation should add fewer than (1536-1518 = 18) 18 extra bytes.

BTW, always leave a few extra bytes at the end of the data buffer.
You never know when some chip might decide to dribble an extra word or
two, or include the CRC because someone frobbed the driver.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
