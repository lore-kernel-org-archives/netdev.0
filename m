From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/6] tcp_memcontrol: Remove tcp_max_memory
Date: Sat, 19 Oct 2013 16:24:02 -0700
Message-ID: <87li1ohmjx.fsf@xmission.com>
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


This function is never called. Remove it.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/tcp_memcontrol.h |    1 -
 net/ipv4/tcp_memcontrol.c    |   13 -------------
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 7df18bc43a97..88cdd1cb992e 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -14,6 +14,5 @@ struct tcp_memcontrol {
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
 void tcp_destroy_cgroup(struct mem_cgroup *memcg);
-unsigned long long tcp_max_memory(const struct mem_cgroup *memcg);
 void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx);
 #endif /* _TCP_MEMCG_H */
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 559d4ae6ebf4..82985d1dc9af 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -226,19 +226,6 @@ static int tcp_cgroup_reset(struct cgroup_subsys_state *css, unsigned int event)
 	return 0;
 }
 
-unsigned long long tcp_max_memory(const struct mem_cgroup *memcg)
-{
-	struct tcp_memcontrol *tcp;
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup((struct mem_cgroup *)memcg);
-	if (!cg_proto)
-		return 0;
-
-	tcp = tcp_from_cgproto(cg_proto);
-	return res_counter_read_u64(&tcp->tcp_memory_allocated, RES_LIMIT);
-}
-
 void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx)
 {
 	struct tcp_memcontrol *tcp;
-- 
1.7.5.4
