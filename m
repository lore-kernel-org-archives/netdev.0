From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/4] drivers/net/enic: decrement sizeof size in strncmp
Date: Thu, 12 Nov 2009 08:48:37 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911120848100.16627@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Scott Feldman <scofeldm@cisco.com>,
	Joe Eykholt <jeykholt@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752034AbZKLHsh@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

As observed by Joe Perches, sizeof of a constant string includes the
trailing 0.  If what is wanted is to check the initial characters of
another string, this trailing 0 should not be taken into account.  If an
exact match is wanted, strcmp should be used instead.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression foo;
constant char *abc;
@@

strncmp(foo, abc, 
- sizeof(abc)
+ sizeof(abc)-1
 )
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/enic/vnic_dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -u -p a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -358,9 +358,9 @@ int vnic_dev_hw_version(struct vnic_dev 
 	if (err)
 		return err;
 
-	if (strncmp(fw_info->hw_version, "A1", sizeof("A1")) == 0)
+	if (strncmp(fw_info->hw_version, "A1", sizeof("A1") - 1) == 0)
 		*hw_ver = VNIC_DEV_HW_VER_A1;
-	else if (strncmp(fw_info->hw_version, "A2", sizeof("A2")) == 0)
+	else if (strncmp(fw_info->hw_version, "A2", sizeof("A2") - 1) == 0)
 		*hw_ver = VNIC_DEV_HW_VER_A2;
 	else
 		*hw_ver = VNIC_DEV_HW_VER_UNKNOWN;
