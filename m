From: Armin Abfalterer <armina@ifi.uio.no>
Subject: tcp_sock variable initialization
Date: Fri, 18 Sep 2009 10:50:59 +0200
Message-ID: <1253263859.4539.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50656 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbZIRIvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 04:51:12 -0400
Received: from mail-mx2.uio.no ([129.240.10.30])
	by mail-out2.uio.no with esmtp (Exim 4.69)
	(envelope-from <armina@ifi.uio.no>)
	id 1MoZBS-0004oO-UP
	for netdev@vger.kernel.org; Fri, 18 Sep 2009 10:51:14 +0200
Received: from cm-84.215.22.41.getinternet.no ([84.215.22.41] helo=[192.168.0.3])
	by mail-mx2.uio.no with esmtpsa (SSLv3:CAMELLIA256-SHA:256)
	user armina (Exim 4.69)
	(envelope-from <armina@ifi.uio.no>)
	id 1MoZBS-0003UO-KF
	for netdev@vger.kernel.org; Fri, 18 Sep 2009 10:51:14 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I need a control variable (ecnn_flags) in tcp_sock that should be set
properly after the 3-way-handshake in tcp_create_openreq_child(). If I
set the variable in its value is always 0 afterwards.

struct sock *tcp_create_openreq_child( ... )
{
	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);

	if (newsk != NULL) {
		struct tcp_sock *newtp;

		newtp = tcp_sk(newsk);
		newtp->ecnn_flags |= TCP_ECN_NONCE_OK;
	}
}

When I read the variable for the next outgoing segment the values is not
set.

static int tcp_transmit_skb( ... )
{
	struct tcp_sock *tp;

	
	if (tp->ecnn_flags & TCP_ECN_NONCE_OK) {
		/*
		* never entered!!!!
		*/
	}
}

I'm quite sure that it has to do with the creation of the big socket
when the connection enters TCP_ESTABLISHED but searching for hours
didn't help to find the right place where my variable is re-initialized.

Any hint in the right direction would greatly appreciated!!! Thanks!

Armin

