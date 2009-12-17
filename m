From: bernard pidoux <f6bvp@free.fr>
Subject: [PATCH] [Resend] rose_loopback_timer sets VC number <=
 ROSE_DEFAULT_MAXVC
Date: Thu, 17 Dec 2009 16:25:18 +0100
Message-ID: <1261063518.20057.22.camel@f6bvp-11>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Linux netdev <netdev@vger.kernel.org>,
	Linux Hams <linux-hams@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] [Resend] rose_loopback_timer sets VC number <= ROSE_DEFAULT_MAXVC

cat /proc/net/rose displayed a rose sockets abnormal lci value, i.e.
greater than maximum number of VCs per neighbour allowed.
This number prevents further test of lci value during rose operations.

Example (lines shortened) :
[bernard]# cat /proc/net/rose
dest_addr  dest_call src_addr   src_call  dev   lci neigh st vs vr va
*          *         2080175520 F6BVP-1   rose0 000 00000  0  0  0  0
2080175520 FPAD-0    2080175520 WP-0      rose0 FFE 00001  3  0  0  0

Here are the default parameters :

linux/include/net/rose.h:#define ROSE_DEFAULT_MAXVC 50 /* Maximum number of VCs per neighbour */
linux/net/rose/af_rose.c:int sysctl_rose_maximum_vcs = ROSE_DEFAULT_MAXVC;

With the following patch, rose_loopback_timer() attributes a VC number
within limits.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 net/rose/rose_loopback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rose/rose_loopback.c b/net/rose/rose_loopback.c
index 114df6e..968e8ba 100644
--- a/net/rose/rose_loopback.c
+++ b/net/rose/rose_loopback.c
@@ -75,7 +75,7 @@ static void rose_loopback_timer(unsigned long param)
 		lci_i     = ((skb->data[0] << 8) & 0xF00) + ((skb->data[1] << 0) & 0x0FF);
 		frametype = skb->data[2];
 		dest      = (rose_address *)(skb->data + 4);
-		lci_o     = 0xFFF - lci_i;
+		lci_o     = ROSE_DEFAULT_MAXVC + 1 - lci_i;
 
 		skb_reset_transport_header(skb);
 
-- 
1.6.0.6

