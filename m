From: Andi Kleen <ak@suse.de>
Subject: Re: ip a flush problem on 2.6 kernels (fine on 2.4 kernels)
Date: Thu, 4 Mar 2004 14:13:19 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040304141319.2d1cb112.ak@suse.de>
References: <200403040308.15880.arekm@pld-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Arkadiusz Miskiewicz <arekm@pld-linux.org>
In-Reply-To: <200403040308.15880.arekm@pld-linux.org>
List-Id: netdev.vger.kernel.org

On Thu, 4 Mar 2004 03:08:15 +0100
Arkadiusz Miskiewicz <arekm@pld-linux.org> wrote:

> The problem is that
> 
> ip a a 192.168.0.1/24 dev eth0
> ip link set eth0 down
> ip a flush dev eth0
> 
> Here on my vanilla 2.6.2 it locks eating CPU - it does netlink 
> communication over and over. This ,,hang'' doesn't happen when 
> interface is in UP state. Also doesn't happen on 2.4 kernels.

I fixed it with this patch for iproute2 here. It's not clear to me at 
all how it ever worked before. The loop seems to be just wrong.

-Andi

diff -u iproute2/ip/ipaddress.c~ iproute2/ip/ipaddress.c
--- iproute2/ip/ipaddress.c~	2004-03-07 20:54:52.000000000 +0100
+++ iproute2/ip/ipaddress.c	2004-03-07 21:02:12.000000000 +0100
@@ -623,6 +623,9 @@
 				fflush(stdout);
 				return 0;
 			}
+#if 1
+			break; 
+#else
 			round++;
 			if (flush_update() < 0)
 				exit(1);
@@ -630,6 +633,7 @@
 				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
 				fflush(stdout);
 			}
+#endif
 		}
 	}
 
