From: Willy Tarreau <w@1wt.eu>
Subject: Please backport commit to 3.12+
Date: Fri, 6 Nov 2015 17:21:19 +0100
Message-ID: <20151106162119.GA23564@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:49887 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932318AbbKFQVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2015 11:21:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We recently faced the issue described in the patch below on 3.14.56. This fix
was merged in 4.2-rc7. I checked Davem's queue and stable queue and it's not
there yet. Could we please have it in 3.12 and above ? (feature was introduced
in 3.11). I can confirm that it properly fixes the problem for us.

Mainline commit is :

  commit 3c16241c445303a90529565e7437e1f240acfef2
  Author: Phil Sutter <phil@nwl.cc>
  Date:   Tue Jul 28 00:53:26 2015 +0200

    netfilter: SYNPROXY: fix sending window update to client
    
    Upon receipt of SYNACK from the server, ipt_SYNPROXY first sends back an ACK to
    finish the server handshake, then calls nf_ct_seqadj_init() to initiate
    sequence number adjustment of forwarded packets to the client and finally sends
    a window update to the client to unblock it's TX queue.
    
    Since synproxy_send_client_ack() does not set synproxy_send_tcp()'s nfct
    parameter, no sequence number adjustment happens and the client receives the
    window update with incorrect sequence number. Depending on client TCP
    implementation, this leads to a significant delay (until a window probe is
    being sent).
    
    Signed-off-by: Phil Sutter <phil@nwl.cc>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks,
Willy
