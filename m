From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 3/28] net/airo: replace schedule_timeout() with
	msleep()/ssleep()
Date: Thu, 6 Jan 2005 15:34:19 -0800
Message-ID: <20050106233419.GD3055@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============13428688021808211=="
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: kernel-janitors@lists.osdl.org
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============13428688021808211==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Description: Use msleep()/ssleep() instead of schedule_timeout() to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-v/drivers/net/wireless/airo.c	2004-12-24 13:33:59.000000000 -0800
+++ 2.6.10/drivers/net/wireless/airo.c	2005-01-04 14:57:49.000000000 -0800
@@ -1699,9 +1699,8 @@ static int readBSSListRid(struct airo_in
 			issuecommand(ai, &cmd, &rsp);
 			up(&ai->sem);
 			/* Let the command take effect */
-			set_current_state (TASK_INTERRUPTIBLE);
 			ai->task = current;
-			schedule_timeout (3*HZ);
+			ssleep(3);
 			ai->task = NULL;
 		}
 	rc = PC4500_readrid(ai, first ? RID_BSSLISTFIRST : RID_BSSLISTNEXT,
@@ -2686,11 +2685,9 @@ int reset_card( struct net_device *dev ,
 		return -1;
 	waitbusy (ai);
 	OUT4500(ai,COMMAND,CMD_SOFTRESET);
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/5);
+	msleep(200);
 	waitbusy (ai);
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/5);
+	msleep(200);
 	if (lock)
 		up(&ai->sem);
 	return 0;
@@ -5518,12 +5515,12 @@ static int airo_pci_resume(struct pci_de
 	} else {
 		OUT4500(ai, EVACK, EV_AWAKEN);
 		OUT4500(ai, EVACK, EV_AWAKEN);
-		schedule_timeout(HZ/10);
+		msleep(100);
 	}
 
 	set_bit (FLAG_COMMIT, &ai->flags);
 	disable_MAC(ai, 0);
-        schedule_timeout (HZ/5);
+        msleep(200);
 	if (ai->SSID) {
 		writeSsidRid(ai, ai->SSID, 0);
 		kfree(ai->SSID);
@@ -7472,8 +7469,7 @@ int cmdreset(struct airo_info *ai) {
 
 	OUT4500(ai,COMMAND,CMD_SOFTRESET);
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* WAS 600 12/7/00 */
+	ssleep(1);			/* WAS 600 12/7/00 */
 
 	if(!waitbusy (ai)){
 		printk(KERN_INFO "Waitbusy hang AFTER RESET\n");
@@ -7500,8 +7496,7 @@ int setflashmode (struct airo_info *ai) 
 		OUT4500(ai, SWS3, FLASH_COMMAND);
 		OUT4500(ai, COMMAND,0);
 	}
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ/2); /* 500ms delay */
+	msleep(500);		/* 500ms delay */
 
 	if(!waitbusy(ai)) {
 		clear_bit (FLAG_FLASHING, &ai->flags);
@@ -7611,8 +7606,7 @@ int flashputbuf(struct airo_info *ai){
 int flashrestart(struct airo_info *ai,struct net_device *dev){
 	int    i,status;
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* Added 12/7/00 */
+	ssleep(1);			/* Added 12/7/00 */
 	clear_bit (FLAG_FLASHING, &ai->flags);
 	if (test_bit(FLAG_MPI, &ai->flags)) {
 		status = mpi_init_descriptors(ai);
@@ -7627,8 +7621,7 @@ int flashrestart(struct airo_info *ai,st
 				( ai, 2312, i >= MAX_FIDS / 2 );
 		}
 
-	set_current_state (TASK_UNINTERRUPTIBLE);
-	schedule_timeout (HZ);          /* Added 12/7/00 */
+	ssleep(1);			/* Added 12/7/00 */
 	return status;
 }
 #endif /* CISCO_EXT */

--===============13428688021808211==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============13428688021808211==--
