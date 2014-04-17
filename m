From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch iproute2 RFC v3 1/5] iproute2: arpd: use
	ll_addr_a2n and ll_addr_n2a
Date: Thu, 17 Apr 2014 14:17:29 +0200
Message-ID: <1397737053-11892-2-git-send-email-jiri@resnulli.us>
References: <1397736876-11771-1-git-send-email-jiri@resnulli.us>
 <1397737053-11892-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
 linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1397737053-11892-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 misc/arpd.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/misc/arpd.c b/misc/arpd.c
index bfe7de9..0839e3f 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -36,6 +36,7 @@
 
 #include "libnetlink.h"
 #include "utils.h"
+#include "rt_names.h"
 
 int resolve_hosts;
 
@@ -721,8 +722,7 @@ int main(int argc, char **argv)
 				goto do_abort;
 			}
 
-			dbdat.data = hexstring_a2n(macbuf, b1, 6);
-			if (dbdat.data == NULL)
+			if (ll_addr_a2n((char *) b1, 6, macbuf) != 6)
 				goto do_abort;
 			dbdat.size = 6;
 
@@ -747,7 +747,7 @@ int main(int argc, char **argv)
 					printf("%-8d %-15s %s\n",
 					       key->iface,
 					       inet_ntoa(*(struct in_addr*)&key->addr),
-					       hexstring_n2a(dbdat.data, 6, b1, 18));
+					       ll_addr_n2a(dbdat.data, 6, ARPHRD_ETHER, b1, 18));
 				} else {
 					printf("%-8d %-15s FAILED: %dsec ago\n",
 					       key->iface,
-- 
1.9.0
