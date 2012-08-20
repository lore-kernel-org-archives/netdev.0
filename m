From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] Interface for TCP Metrics
Date: Mon, 20 Aug 2012 09:30:09 -0700
Message-ID: <20120820093009.519d9bec@nehalam.linuxnetplumber.net>
References: <alpine.LFD.2.00.1208191402560.1893@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34923 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755549Ab2HTQa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 12:30:27 -0400
In-Reply-To: <alpine.LFD.2.00.1208191402560.1893@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 19 Aug 2012 14:42:15 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 
> 	Hello,
> 
> 	Once DaveM mentioned that TCP Metrics need their
> own interface. I'm planning to implement such interface
> but lets first decide how it should look. After little
> research, here is my plan:
> 
> - will use genl with TCP_METRICS_GENL_NAME "tcp_metrics",
> TCP_METRICS_GENL_VERSION 0x01

Ok, but don't use libnl in iproute

> - provide dumpit method and one cmd to read metrics by exact addr,
> will use TCP_METRICS_CMD_{GET,...} and TCP_METRICS_ATTR_xxx in
> new file include/linux/tcp_metrics.h

Doing filtering in use space is fine, no need to be too fancy.

> - Is command to delete cached entry needed? Delete will need
> new rcu_head. Useful to flush the cache or to delete entries
> with filter.
> 
> - without support for delete cmd, may be we can add command to
> reset entry with default values from dst?
> 
> - Where to put the new netlink code?
> tcp_metrics_netlink.c
> tcp_metrics_nl.c
> or just in current tcp_metrics.c ?
> 
> - will provide support for ip tool:
> 
