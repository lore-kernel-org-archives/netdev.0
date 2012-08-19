From: Julian Anastasov <ja@ssi.bg>
Subject: [RFC] Interface for TCP Metrics
Date: Sun, 19 Aug 2012 14:42:15 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208191402560.1893@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50969 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410Ab2HSLkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Aug 2012 07:40:40 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q7JBgFDH002510
	for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 14:42:15 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

	Once DaveM mentioned that TCP Metrics need their
own interface. I'm planning to implement such interface
but lets first decide how it should look. After little
research, here is my plan:

- will use genl with TCP_METRICS_GENL_NAME "tcp_metrics",
TCP_METRICS_GENL_VERSION 0x01

- provide dumpit method and one cmd to read metrics by exact addr,
will use TCP_METRICS_CMD_{GET,...} and TCP_METRICS_ATTR_xxx in
new file include/linux/tcp_metrics.h

- Is command to delete cached entry needed? Delete will need
new rcu_head. Useful to flush the cache or to delete entries
with filter.

- without support for delete cmd, may be we can add command to
reset entry with default values from dst?

- Where to put the new netlink code?
tcp_metrics_netlink.c
tcp_metrics_nl.c
or just in current tcp_metrics.c ?

- will provide support for ip tool:

ip tcpm[etrics] <cmd> ...
ip -6 tcpm[etrics] get <addr> => TCP_METRICS_CMD_GET for 1 entry
ip tcpm[etrics] list => dumpit

- any wishes how to look the output? How to select specific
values/metrics in output? For example, list only specified
named values: ip tcpm list [-o] rtt

- command to modify specific metric for addr, by name? Only
for tcpm_vals? If not locked?

	Do we need modify/delete/reset support or just read
support is enough? Comments?

Regards

--
Julian Anastasov <ja@ssi.bg>
