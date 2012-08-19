From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Interface for TCP Metrics
Date: Sun, 19 Aug 2012 15:50:24 +0200
Message-ID: <1345384224.5158.210.camel@edumazet-glaptop>
References: <alpine.LFD.2.00.1208191402560.1893@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:60846 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687Ab2HSNu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 09:50:28 -0400
Received: by wibhr14 with SMTP id hr14so3005828wib.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 06:50:27 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1208191402560.1893@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-08-19 at 14:42 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> 	Once DaveM mentioned that TCP Metrics need their
> own interface. I'm planning to implement such interface
> but lets first decide how it should look. After little
> research, here is my plan:
> 
> - will use genl with TCP_METRICS_GENL_NAME "tcp_metrics",
> TCP_METRICS_GENL_VERSION 0x01
> 
> - provide dumpit method and one cmd to read metrics by exact addr,
> will use TCP_METRICS_CMD_{GET,...} and TCP_METRICS_ATTR_xxx in
> new file include/linux/tcp_metrics.h
> 
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
> ip tcpm[etrics] <cmd> ...
> ip -6 tcpm[etrics] get <addr> => TCP_METRICS_CMD_GET for 1 entry
> ip tcpm[etrics] list => dumpit
> 
> - any wishes how to look the output? How to select specific
> values/metrics in output? For example, list only specified
> named values: ip tcpm list [-o] rtt
> 
> - command to modify specific metric for addr, by name? Only
> for tcpm_vals? If not locked?
> 
> 	Do we need modify/delete/reset support or just read
> support is enough? Comments?
> 
> Regards

One way to delete one or all entries would be good, for being able to
reproduce some tests from a known state.
