From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] via-rhine: references __init code during resume
Date: Mon, 01 Nov 2004 09:21:48 -0800
Message-ID: <418670AC.7010801@osdl.org>
References: <4179543F.1020407@osdl.org> <418390F2.7080901@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060901020707080309020307"
Cc: netdev@oss.sgi.com, rl@hellgate.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <418390F2.7080901@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060901020707080309020307
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

[Does it work if the patch description is inline & the
patch is attached?]


Fix __init section usage:
rhine_resume calls enable_mmio, so latter cannot be __devinit;
Error: ./drivers/net/via-rhine.o .text refers to 0000000000000925 
R_X86_64_PC32     .init.text+0xfffffffffffffffc

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  drivers/net/via-rhine.c |    2 +-
  1 files changed, 1 insertion(+), 1 deletion(-)

-- 
~Randy

--------------060901020707080309020307
Content-Type: text/x-patch;
 name="via_rhine_mmio.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="via_rhine_mmio.patch"

diff -Naurp ./drivers/net/via-rhine.c~via_rhine_mmio ./drivers/net/via-rhine.c
--- ./drivers/net/via-rhine.c~via_rhine_mmio	2004-10-18 14:55:28.000000000 -0700
+++ ./drivers/net/via-rhine.c	2004-10-22 10:10:58.928311448 -0700
@@ -627,7 +627,7 @@ static void rhine_chip_reset(struct net_
 }
 
 #ifdef USE_MMIO
-static void __devinit enable_mmio(long pioaddr, u32 quirks)
+static void enable_mmio(long pioaddr, u32 quirks)
 {
 	int n;
 	if (quirks & rqRhineI) {

--------------060901020707080309020307--
