From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 6/6] ipv4: Allow unprivileged users to use per net sysctls
Date: Sat, 19 Oct 2013 16:27:35 -0700
Message-ID: <87ppr0g7tk.fsf@xmission.com>
References: <87r4bghml4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r4bghml4.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sat, 19 Oct 2013 16:23:19 -0700")
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


Allow unprivileged users to use:
/proc/sys/net/ipv4/icmp_echo_ignore_all
/proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
/proc/sys/net/ipv4/icmp_ignore_bogus_error_response
/proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
/proc/sys/net/ipv4/icmp_ratelimit
/proc/sys/net/ipv4/icmp_ratemask
/proc/sys/net/ipv4/ping_group_range
/proc/sys/net/ipv4/tcp_ecn
/proc/sys/net/ipv4/ip_local_ports_range

These are occassionally handy and after a quick review I don't see
any problems with unprivileged users using them.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/ipv4/sysctl_net_ipv4.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 5a17eb605f77..3298255d0ae7 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -842,10 +842,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 		/* Update the variables to point into the current struct net */
 		for (i = 0; i < ARRAY_SIZE(ipv4_net_table) - 1; i++)
 			table[i].data += (void *)net - (void *)&init_net;
-
-		/* Don't export sysctls to unprivileged users */
-		if (net->user_ns != &init_user_ns)
-			table[0].procname = NULL;
 	}
 
 	/*
-- 
1.7.5.4
