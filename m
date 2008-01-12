From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH 3/4] [ROSE] return with lock held
Date: Sat, 12 Jan 2008 21:20:15 +0100
Message-ID: <478920FF.5010104@ccr.jussieu.fr>
References: <47630274.1080706@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:43502 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762726AbYALUUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 15:20:18 -0500
In-Reply-To: <47630274.1080706@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From bc108e5ee0b0353c3707df25e12e40038da0160a Mon Sep 17 00:00:00 2001
From: Bernard Pidoux <f6bvp@amsat.org>
Date: Fri, 11 Jan 2008 10:23:55 +0100
Subject: [PATCH 3/4] [ROSE] return with lock held

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>

================================================
[ BUG: lock held when returning to user space! ]

------------------------------------------------
fpacwpd/3057 is leaving the kernel with locks still held!
1 lock held by fpacwpd/3057:
#0:  (sk_lock-AF_ROSE){--..}, at: [<d8bfda7f>] rose_connect+0x6c/0x357 
[rose]
---
  net/rose/af_rose.c |    3 ++-
  1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8f70ad8..9419946 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -752,7 +752,8 @@ static int rose_connect(struct socket *sock, struct 
sockaddr *uaddr, int addr_le
         rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause,
                                          &diagnostic);
         if (!rose->neighbour)
-               return -ENETUNREACH;
+               err = -ENETUNREACH;
+               goto out_release;

         rose->lci = rose_new_lci(rose->neighbour);
         if (!rose->lci) {
--
1.5.3.7


