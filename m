From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] Fix crash on big-endian systems during scan
Date: Fri, 14 Apr 2006 17:59:11 -0400
Message-ID: <20060414215911.17273.40460.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: netdev@vger.kernel.org
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

The original code was doing arithmetics on a little-endian value.
Reported by Stelios Koroneos <stelios@stelioscellar.com>

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/hostap/hostap_ioctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 8b37e82..8399de5 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1860,7 +1860,7 @@ static char * __prism2_translate_scan(lo
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
 	if (scan) {
-		chan = scan->chid;
+		chan = le16_to_cpu(scan->chid);
 	} else if (bss) {
 		chan = bss->chan;
 	} else {
@@ -1868,7 +1868,7 @@ static char * __prism2_translate_scan(lo
 	}
 
 	if (chan > 0) {
-		iwe.u.freq.m = freq_list[le16_to_cpu(chan - 1)] * 100000;
+		iwe.u.freq.m = freq_list[chan - 1] * 100000;
 		iwe.u.freq.e = 1;
 		current_ev = iwe_stream_add_event(current_ev, end_buf, &iwe,
 						  IW_EV_FREQ_LEN);
