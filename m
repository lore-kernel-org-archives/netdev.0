From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] include listenq max backlog in /proc/net/tcp and	include
 in tcp_info
Date: Tue, 11 Sep 2007 08:54:15 +0200
Message-ID: <46E63B97.8030304@cosmosbay.com>
References: <200709102313.QAA01722@tardy.cup.hp.com> <1189471180.11066.19.camel@w-sridhar2.beaverton.ibm.com> <46E63121.5090607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030108070706090007060503"
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55955 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbXIKHQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 03:16:28 -0400
In-Reply-To: <46E63121.5090607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030108070706090007060503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Eric Dumazet a écrit :
> Sridhar Samudrala a écrit :
>> On Mon, 2007-09-10 at 16:13 -0700, Rick Jones wrote:
>>> Return some useful information such as the maximum listen backlog and
>>> the current listen backlog in the tcp_info structure and have that 
>>> match what one can see in /proc/net/tcp and /proc/net/tcp6.
>>
>> If we are also exporting max listen backlog, another place to
>> consider adding this is to tcp_diag_get_info() called via INET_DIAG_INFO.
>> Current listen backlog is returned in inet_diag_msg->idiag_rqueue.
>> max listen backlog can be returned in inet_diag_msg->idiag_wqueue.
>>
> 
> I agree, /proc/net/tcp is deprecated nowadays...
> 
> Rick, could you add this part in your patch, and add my Sign-off-by ?
> 
> Thank you
> Eric

One } was missing, sorry


--------------030108070706090007060503
Content-Type: text/plain;
 name="diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff"

diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 57c5f0b..f5b6275 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -25,11 +25,13 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_info *info = _info;
 
-	if (sk->sk_state == TCP_LISTEN)
+	if (sk->sk_state == TCP_LISTEN) {
 		r->idiag_rqueue = sk->sk_ack_backlog;
-	else
+		r->idiag_wqueue = sk->sk_max_ack_backlog;
+	} else {
 		r->idiag_rqueue = tp->rcv_nxt - tp->copied_seq;
-	r->idiag_wqueue = tp->write_seq - tp->snd_una;
+		r->idiag_wqueue = tp->write_seq - tp->snd_una;
+	}
 	if (info != NULL)
 		tcp_get_info(sk, info);
 }

--------------030108070706090007060503--
