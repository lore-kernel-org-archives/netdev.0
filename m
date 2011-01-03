From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: [PATCH] depca: Fix section mismatch derived from depca_isa_probe()
Date: Mon,  3 Jan 2011 22:22:15 +0100
Message-ID: <1294089735-3031-1-git-send-email-sedat.dilek@gmail.com>
Cc: Sedat Dilek <sedat.dilek@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the following warning:

WARNING: drivers/net/depca.o(.data+0x0): Section mismatch in reference from the variable depca_isa_driver to the function .init.text:depca_isa_probe()
The variable depca_isa_driver references
the function __init depca_isa_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

Tested with linux-next (next-20101231)

Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>
---
 drivers/net/depca.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 91b3846..1b48b68 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -1513,7 +1513,7 @@ static enum depca_type __init depca_shmem_probe (ulong *mem_start)
 	return adapter;
 }
 
-static int __init depca_isa_probe (struct platform_device *device)
+static int __devinit depca_isa_probe (struct platform_device *device)
 {
 	struct net_device *dev;
 	struct depca_private *lp;
-- 
1.7.4.rc0
