From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch iproute2 RFC v3 2/5] iproute2: utils: change
	hexstring_n2a and hexstring_a2n to do not work with ":"
Date: Thu, 17 Apr 2014 14:17:30 +0200
Message-ID: <1397737053-11892-3-git-send-email-jiri@resnulli.us>
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
 lib/utils.c | 46 +++++++++++++---------------------------------
 1 file changed, 13 insertions(+), 33 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 4e9c719..e9e1040 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -743,10 +743,6 @@ char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen)
 		sprintf(ptr, "%02x", str[i]);
 		ptr += 2;
 		blen -= 2;
-		if (i != len-1 && blen > 1) {
-			*ptr++ = ':';
-			blen--;
-		}
 	}
 	return buf;
 }
@@ -754,38 +750,22 @@ char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen)
 __u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
 {
 	int cnt = 0;
+	char *endptr;
 
-	for (;;) {
-		unsigned acc;
-		char ch;
-
-		acc = 0;
-
-		while ((ch = *str) != ':' && ch != 0) {
-			if (ch >= '0' && ch <= '9')
-				ch -= '0';
-			else if (ch >= 'a' && ch <= 'f')
-				ch -= 'a'-10;
-			else if (ch >= 'A' && ch <= 'F')
-				ch -= 'A'-10;
-			else
-				return NULL;
-			acc = (acc<<4) + ch;
-			str++;
-		}
-
-		if (acc > 255)
+	if (strlen(str) % 2)
+		return NULL;
+	while (cnt < blen && strlen(str) > 1) {
+		unsigned int tmp;
+		char tmpstr[3];
+
+		strncpy(tmpstr, str, 2);
+		tmpstr[2] = '\0';
+		tmp = strtoul(tmpstr, &endptr, 16);
+		if (errno != 0 || tmp > 0xFF || *endptr != '\0')
 			return NULL;
-		if (cnt < blen) {
-			buf[cnt] = acc;
-			cnt++;
-		}
-		if (ch == 0)
-			break;
-		++str;
+		buf[cnt++] = tmp;
+		str += 2;
 	}
-	if (cnt < blen)
-		memset(buf+cnt, 0, blen-cnt);
 	return buf;
 }
 
-- 
1.9.0
