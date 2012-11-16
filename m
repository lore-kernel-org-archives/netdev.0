From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 08/17] net: Allow userns root to force the scm creds
Date: Fri, 16 Nov 2012 05:03:03 -0800
Message-ID: <1353070992-5552-8-git-send-email-ebiederm@xmission.com>
References: <87d2zd8zwn.fsf@xmission.com>
	<1353070992-5552-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353070992-5552-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

If the user calling sendmsg has the appropriate privieleges
in their user namespace allow them to set the uid, gid, and
pid in the SCM_CREDENTIALS control message to any valid value.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/scm.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index ab57084..57fb1ee 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -51,11 +51,11 @@ static __inline__ int scm_check_creds(struct ucred *creds)
 	if (!uid_valid(uid) || !gid_valid(gid))
 		return -EINVAL;
 
-	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
+	if ((creds->pid == task_tgid_vnr(current) || nsown_capable(CAP_SYS_ADMIN)) &&
 	    ((uid_eq(uid, cred->uid)   || uid_eq(uid, cred->euid) ||
-	      uid_eq(uid, cred->suid)) || capable(CAP_SETUID)) &&
+	      uid_eq(uid, cred->suid)) || nsown_capable(CAP_SETUID)) &&
 	    ((gid_eq(gid, cred->gid)   || gid_eq(gid, cred->egid) ||
-	      gid_eq(gid, cred->sgid)) || capable(CAP_SETGID))) {
+	      gid_eq(gid, cred->sgid)) || nsown_capable(CAP_SETGID))) {
 	       return 0;
 	}
 	return -EPERM;
-- 
1.7.5.4
