From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] atm: fix horizon init section usage
Date: Sun, 22 Oct 2006 19:13:09 -0700
Message-ID: <20061022191309.73e3eacd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:1068 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1751169AbWJWCLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 22:11:51 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

hrz_init() is called from the probe function, which is __devinit
and could be called after init.

WARNING: drivers/atm/horizon.o - Section mismatch: reference to .init.text:.hrz_init from .text between '.hrz_probe' (at offset 0x4054) and '.hrz_remove_one'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---

 drivers/atm/horizon.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -Naurp linux-2619-rc2g4/drivers/atm/horizon.c~atm_hrz_section linux-2619-rc2g4/drivers/atm/horizon.c
--- linux-2619-rc2g4/drivers/atm/horizon.c~atm_hrz_section	2006-10-20 17:37:52.822837000 -0700
+++ linux-2619-rc2g4/drivers/atm/horizon.c	2006-10-21 22:36:53.373243000 -0700
@@ -1845,7 +1845,8 @@ static u16 __init read_bia (const hrz_de
 
 /********** initialise a card **********/
 
-static int __init hrz_init (hrz_dev * dev) {
+static int hrz_init (hrz_dev * dev)
+{
   int onefivefive;
   
   u16 chan;


---
