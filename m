From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH 1/3] NET: am79c961: ensure asm() statements are marked
 volatile
Date: Fri, 10 Jun 2011 11:51:54 +0100
Message-ID: <E1QUzJi-0004B6-HH@rmk-PC.arm.linux.org.uk>
References: <20110610105122.GA27087@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35112 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730Ab1FJKv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 06:51:58 -0400
Received: from e0022681537dd.dyn.arm.linux.org.uk ([2002:4e20:1eda:1:222:68ff:fe15:37dd] helo=rmk-PC.arm.linux.org.uk)
	by caramon.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1QUzJj-0006Q2-HC
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:51:55 +0100
Received: from rmk by rmk-PC.arm.linux.org.uk with local (Exim 4.76)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1QUzJi-0004B6-HH
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:51:54 +0100
In-Reply-To: <20110610105122.GA27087@flint.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this the compiler can (and does) optimize register reads away
from within loops, and other such optimizations.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/arm/am79c961a.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 0c9217f..084b67f 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -50,7 +50,7 @@ static const char version[] =
 #ifdef __arm__
 static void write_rreg(u_long base, u_int reg, u_int val)
 {
-	__asm__(
+	asm volatile(
 	"str%?h	%1, [%2]	@ NET_RAP\n\t"
 	"str%?h	%0, [%2, #-4]	@ NET_RDP"
 	:
@@ -60,7 +60,7 @@ static void write_rreg(u_long base, u_int reg, u_int val)
 static inline unsigned short read_rreg(u_long base_addr, u_int reg)
 {
 	unsigned short v;
-	__asm__(
+	asm volatile(
 	"str%?h	%1, [%2]	@ NET_RAP\n\t"
 	"ldr%?h	%0, [%2, #-4]	@ NET_RDP"
 	: "=r" (v)
@@ -70,7 +70,7 @@ static inline unsigned short read_rreg(u_long base_addr, u_int reg)
 
 static inline void write_ireg(u_long base, u_int reg, u_int val)
 {
-	__asm__(
+	asm volatile(
 	"str%?h	%1, [%2]	@ NET_RAP\n\t"
 	"str%?h	%0, [%2, #8]	@ NET_IDP"
 	:
@@ -80,7 +80,7 @@ static inline void write_ireg(u_long base, u_int reg, u_int val)
 static inline unsigned short read_ireg(u_long base_addr, u_int reg)
 {
 	u_short v;
-	__asm__(
+	asm volatile(
 	"str%?h	%1, [%2]	@ NAT_RAP\n\t"
 	"ldr%?h	%0, [%2, #8]	@ NET_IDP\n\t"
 	: "=r" (v)
@@ -131,7 +131,7 @@ am_readbuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned
 	length = (length + 1) & ~1;
 	if ((int)buf & 2) {
 		unsigned int tmp;
-		__asm__ __volatile__(
+		asm volatile(
 			"ldr%?h	%2, [%0], #4\n\t"
 			"str%?b	%2, [%1], #1\n\t"
 			"mov%?	%2, %2, lsr #8\n\t"
@@ -141,7 +141,7 @@ am_readbuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned
 	}
 	while (length > 8) {
 		unsigned int tmp, tmp2, tmp3;
-		__asm__ __volatile__(
+		asm volatile(
 			"ldr%?h	%2, [%0], #4\n\t"
 			"ldr%?h	%3, [%0], #4\n\t"
 			"orr%?	%2, %2, %3, lsl #16\n\t"
@@ -155,7 +155,7 @@ am_readbuffer(struct net_device *dev, u_int offset, unsigned char *buf, unsigned
 	}
 	while (length > 0) {
 		unsigned int tmp;
-		__asm__ __volatile__(
+		asm volatile(
 			"ldr%?h	%2, [%0], #4\n\t"
 			"str%?b	%2, [%1], #1\n\t"
 			"mov%?	%2, %2, lsr #8\n\t"
-- 
1.7.4.4

