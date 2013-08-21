From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: tcp_probe: also include rcv_wnd next to snd_wnd
Date: Wed, 21 Aug 2013 19:47:58 +0200
Message-ID: <1377107280-31091-2-git-send-email-dborkman@redhat.com>
References: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab3HURsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 13:48:05 -0400
In-Reply-To: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is helpful to sometimes know the TCP window sizes of an established
socket e.g. to confirm that window scaling is working or to tweak the
window size to improve high-latency connections, etc etc. Currently the
TCP snooper only exports the send window size, but not the receive window
size. Therefore, also add the receive window size to the end of the
output line.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp_probe.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index d4943f6..fae788b 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -60,6 +60,7 @@ struct tcp_log {
 	u32	snd_nxt;
 	u32	snd_una;
 	u32	snd_wnd;
+	u32	rcv_wnd;
 	u32	snd_cwnd;
 	u32	ssthresh;
 	u32	srtt;
@@ -116,6 +117,7 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			p->snd_una = tp->snd_una;
 			p->snd_cwnd = tp->snd_cwnd;
 			p->snd_wnd = tp->snd_wnd;
+			p->rcv_wnd = tp->rcv_wnd;
 			p->ssthresh = tcp_current_ssthresh(sk);
 			p->srtt = tp->srtt >> 3;
 
@@ -157,13 +159,13 @@ static int tcpprobe_sprint(char *tbuf, int n)
 		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
 
 	return scnprintf(tbuf, n,
-			"%lu.%09lu %pI4:%u %pI4:%u %d %#x %#x %u %u %u %u\n",
+			"%lu.%09lu %pI4:%u %pI4:%u %d %#x %#x %u %u %u %u %u\n",
 			(unsigned long) tv.tv_sec,
 			(unsigned long) tv.tv_nsec,
 			&p->saddr, ntohs(p->sport),
 			&p->daddr, ntohs(p->dport),
 			p->length, p->snd_nxt, p->snd_una,
-			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt);
+			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt, p->rcv_wnd);
 }
 
 static ssize_t tcpprobe_read(struct file *file, char __user *buf,
-- 
1.7.1
