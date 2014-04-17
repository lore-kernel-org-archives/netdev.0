From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch iproute2 RFC v3 3/5] iproute2: ipa: show switch id
Date: Thu, 17 Apr 2014 14:17:31 +0200
Message-ID: <1397737053-11892-4-git-send-email-jiri@resnulli.us>
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
 include/linux/if_link.h | 2 ++
 ip/ipaddress.c          | 8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f08505c..2932453 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -144,6 +144,8 @@ enum {
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
+	IFLA_CARRIER_CHANGES,
+	IFLA_PHYS_SWITCH_ID,
 	__IFLA_MAX
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..43f7296 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -470,6 +470,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "master %s ", ll_idx_n2a(*(int*)RTA_DATA(tb[IFLA_MASTER]), b1));
 	}
 
+	if (tb[IFLA_PHYS_SWITCH_ID]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "swid %s ",
+			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
+				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
+				      b1, sizeof(b1)));
+	}
+
 	if (tb[IFLA_OPERSTATE])
 		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
 
-- 
1.9.0
