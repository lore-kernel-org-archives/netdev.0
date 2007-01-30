From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT brokenness?
Date: Wed, 31 Jan 2007 00:28:16 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0701310011450.2627@u.domain.uli>
References: <Pine.LNX.4.64.0612301758160.27326@twinlark.arctic.org>
 <Pine.LNX.4.64.0701300104130.17450@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, mtk-manpages@gmx.net
To: dean gaudet <dean@arctic.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:3905 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751819AbXA3W1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 17:27:46 -0500
In-Reply-To: <Pine.LNX.4.64.0701300104130.17450@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 30 Jan 2007, dean gaudet wrote:

> > which is a bit confusing because it talks both about seconds and
> > "attempts".  (and doesn't mention what happens when the timeout finishes
> > -- i could see dropping the socket or passing it to userland anyhow as
> > possibilities... but in fact the socket is dropped).

	My understanding about SYN-ACKs is:

- there is always one SYN+ACK and at least one retransmission (min 
3+6 secs period to accept ACK)

- TCP_SYNCNT (or tcp_synack_retries) define the number of retransmissions,
this is a minimum that TCP_DEFER_ACCEPT can not reduce (due to the
'req->retrans < thresh' check). It can only extend it after the
ACK is received.

- TCP_DEFER_ACCEPT defines seconds (total time) to wait for ACK
plus first data

	Hint: one option is that you can treat TCP_DEFER_ACCEPT as flag, 
set it to 1 and then tune TCP_SYNCNT to cover the max desired period to 
wait for data.

Regards

--
Julian Anastasov <ja@ssi.bg>
