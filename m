From: Andrew Morton <akpm@osdl.org>
Subject: netif_poll_disable() hangs
Date: Sun, 7 Sep 2003 23:21:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030907232145.6ec197fd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Very simple:

	ifup eth0
	ifdown eth0
	ifup eth0
	ifdown eth0	<- hangs in dev_close -> netif_poll_disable()


Because the first close sets __LINK_STATE_RX_SCHED and nothing ever clears
it.  
