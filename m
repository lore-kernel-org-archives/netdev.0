From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next] tcp: Return bool instead of int where appropriate
Date: Fri, 20 Jul 2012 00:32:18 -0700
Message-ID: <1342769538-4039-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:41990 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab2GTHZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 03:25:10 -0400
Received: by ghrr11 with SMTP id r11so3689255ghr.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 00:25:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied to a set of static inline functions in tcp_input.c

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/ipv4/tcp_input.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e67d685..21d7f8f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2521,7 +2521,7 @@ static void tcp_cwnd_down(struct sock *sk, int flag)
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
-static inline int tcp_packet_delayed(const struct tcp_sock *tp)
+static inline bool tcp_packet_delayed(const struct tcp_sock *tp)
 {
 	return !tp->retrans_stamp ||
 		(tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
@@ -2582,7 +2582,7 @@ static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static inline int tcp_may_undo(const struct tcp_sock *tp)
+static inline bool tcp_may_undo(const struct tcp_sock *tp)
 {
 	return tp->undo_marker && (!tp->undo_retrans || tcp_packet_delayed(tp));
 }
@@ -3371,13 +3371,13 @@ static void tcp_ack_probe(struct sock *sk)
 	}
 }
 
-static inline int tcp_ack_is_dubious(const struct sock *sk, const int flag)
+static inline bool tcp_ack_is_dubious(const struct sock *sk, const int flag)
 {
 	return !(flag & FLAG_NOT_DUP) || (flag & FLAG_CA_ALERT) ||
 		inet_csk(sk)->icsk_ca_state != TCP_CA_Open;
 }
 
-static inline int tcp_may_raise_cwnd(const struct sock *sk, const int flag)
+static inline bool tcp_may_raise_cwnd(const struct sock *sk, const int flag)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	return (!(flag & FLAG_ECE) || tp->snd_cwnd < tp->snd_ssthresh) &&
@@ -3387,7 +3387,7 @@ static inline int tcp_may_raise_cwnd(const struct sock *sk, const int flag)
 /* Check that window update is acceptable.
  * The function assumes that snd_una<=ack<=snd_next.
  */
-static inline int tcp_may_update_window(const struct tcp_sock *tp,
+static inline bool tcp_may_update_window(const struct tcp_sock *tp,
 					const u32 ack, const u32 ack_seq,
 					const u32 nwin)
 {
@@ -4006,7 +4006,7 @@ static int tcp_disordered_ack(const struct sock *sk, const struct sk_buff *skb)
 		(s32)(tp->rx_opt.ts_recent - tp->rx_opt.rcv_tsval) <= (inet_csk(sk)->icsk_rto * 1024) / HZ);
 }
 
-static inline int tcp_paws_discard(const struct sock *sk,
+static inline bool tcp_paws_discard(const struct sock *sk,
 				   const struct sk_buff *skb)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
@@ -4028,7 +4028,7 @@ static inline int tcp_paws_discard(const struct sock *sk,
  * (borrowed from freebsd)
  */
 
-static inline int tcp_sequence(const struct tcp_sock *tp, u32 seq, u32 end_seq)
+static inline bool tcp_sequence(const struct tcp_sock *tp, u32 seq, u32 end_seq)
 {
 	return	!before(end_seq, tp->rcv_wup) &&
 		!after(seq, tp->rcv_nxt + tcp_receive_window(tp));
@@ -5214,7 +5214,7 @@ static __sum16 __tcp_checksum_complete_user(struct sock *sk,
 	return result;
 }
 
-static inline int tcp_checksum_complete_user(struct sock *sk,
+static inline bool tcp_checksum_complete_user(struct sock *sk,
 					     struct sk_buff *skb)
 {
 	return !skb_csum_unnecessary(skb) &&
-- 
1.7.0.4
