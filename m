From: KOVACS Krisztian <hidden@balabit.hu>
Subject: TCP minisock tcp_create_openreq_child() typo?
Date: Wed, 28 Feb 2007 12:03:37 +0100
Message-ID: <200702281203.38112@nienna>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:2932 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752125AbXB1LDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 06:03:43 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 237E2294043
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 12:03:41 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

  While reading TCP minisock code I've found this suspiciously looking
code fragment:

- 8< -
struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req, struct sk_buff *skb)
{
	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);

	if (newsk != NULL) {
		const struct inet_request_sock *ireq = inet_rsk(req);
		struct tcp_request_sock *treq = tcp_rsk(req);
		struct inet_connection_sock *newicsk = inet_csk(sk);
		struct tcp_sock *newtp;
- 8< -

  The above code initializes newicsk to inet_csk(sk), isn't that supposed
to be inet_csk(newsk)?  As far as I can tell this might leave
icsk_ack.last_seg_size zero even if we do have received data.

-- 
 Regards,
  Krisztian Kovacs
