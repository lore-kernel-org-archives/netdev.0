From: Satoru Moriya <satoru.moriya@hds.com>
Subject: [PATCH 0/2] Tracepoint for tcp retransmission
Date: Fri, 16 Dec 2011 17:14:53 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA64F@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps03.hds.com ([207.126.252.16]:59779 "EHLO
	usindpps03.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636Ab1LQAHf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 19:07:35 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes network packets are dropped for some reason. In enterprise
systems which require strict RAS functionality, we must know the
reason why it happened and explain it to our customers even if using
TCP. When we investigate the incidents, at first we try to find out
whether the problem is in the server(kernel, application) or else
(router, hub etc). And next we try to find out which layer
(application/middleware/kernel(IP/TCP/UDP/..)etc.) the problem
occurs.

In application layer, user applications and/or middlewares usually
save logs if they dropped packets. In kernel layer, with this
tracepoint, we are able to know whether the kernel(TCP layer) send
packets successfully or not.

With a combination of them, we can find out whether the problem is
in the server or not.


Satoru Moriya (2):
  tcp: refactor tcp_retransmit_skb() for a single return point
  tcp: add tracepoint for tcp retransmission

 include/trace/events/tcp.h |   35 +++++++++++++++++++++++++++++++++++
 net/core/net-traces.c      |    1 +
 net/ipv4/tcp_output.c      |   34 ++++++++++++++++++++++++----------
 3 files changed, 60 insertions(+), 10 deletions(-)
 create mode 100644 include/trace/events/tcp.h

-- 
1.7.6.4
