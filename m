From: Greg KH <greg@kroah.com>
Subject: [06/11] [TCP]: Put back tcp_timer_bug_msg[] symbol export.
Date: Thu, 10 Mar 2005 15:08:43 -0800
Message-ID: <20050310230843.GG22112@kroah.com>
References: <20050310230519.GA22112@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, stable@kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050310230519.GA22112@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


-stable review patch.  If anyone has any objections, please let us know.

------------------



This wrecks the ipv6 modular build for a lot of people.
In fact, since I always build ipv6 modular I am surprised
I never hit this.  My best guess is that my compiler is
optimizing the reference away, but that can never be
depended upon and the symbol export really is needed.

[TCP]: Put back tcp_timer_bug_msg[] symbol export.
  
It is needed for tcp_reset_xmit_timer(), which is invoked by
tcp_prequeue() which is invoked from tcp_ipv6.c
 
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Chris Wright <chrisw@osdl.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2005-03-09 17:20:38 -08:00
+++ b/net/ipv4/tcp_timer.c	2005-03-09 17:20:38 -08:00
@@ -38,6 +38,7 @@
 
 #ifdef TCP_DEBUG
 const char tcp_timer_bug_msg[] = KERN_DEBUG "tcpbug: unknown timer value\n";
+EXPORT_SYMBOL(tcp_timer_bug_msg);
 #endif
 
 /*
