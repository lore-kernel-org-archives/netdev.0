From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH 4/4] [ROSE] ENETUNREACH held rose_connect()
Date: Sat, 12 Jan 2008 21:23:50 +0100
Message-ID: <478921D6.8070205@ccr.jussieu.fr>
References: <47630274.1080706@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:45309 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758868AbYALUXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 15:23:53 -0500
In-Reply-To: <47630274.1080706@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From 5c50971c6088f380eafdb1a6a7de5a5d3686c8c7 Mon Sep 17 00:00:00 2001
From: Bernard Pidoux <f6bvp@amsat.org>
Date: Sat, 12 Jan 2008 20:19:34 +0100
Subject: [PATCH 4/4] [ROSE] ENETUNREACH held rose_connect()

Initial connection to rose neighbour nodes was unusually,
t0 timer was blocked and application program could not
use socket.
I performed a number of trials in order to find what was
slowing rose_connect() and blocking ROSE t0 timer.
Replacing the type of error returned did not cure the problem.
Finally removing the error returned when rose->neighbour is NULL
is the solution.
Without err = -ENETUNREACH rose_connect() returns default err = 0.
Doing that, t0 timer is running, rose_connect() performs adjacent
rose node connections as needed and rose frames are well routed.
Also, application programs can access rose connect socket.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
  net/rose/af_rose.c |    1 -
  1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 9419946..5a8c886 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -752,7 +752,6 @@ static int rose_connect(struct socket *sock, struct 
sockaddr *uaddr, int addr_le
         rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause,
                                          &diagnostic);
         if (!rose->neighbour)
-               err = -ENETUNREACH;
                 goto out_release;

         rose->lci = rose_new_lci(rose->neighbour);
--
1.5.3.7

