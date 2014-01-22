From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gre: don't pull skb if dealing with icmp message
Date: Tue, 21 Jan 2014 16:49:04 -0800 (PST)
Message-ID: <20140121.164904.1559727284192286374.davem@davemloft.net>
References: <52DB8E4A.7050809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbaAVAtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:49:05 -0500
In-Reply-To: <52DB8E4A.7050809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Sun, 19 Jan 2014 16:35:22 +0800

> 
> When dealing with icmp messages, the skb->data points the
> ip header that triggered the sending of the icmp message.
> 
> In gre_cisco_err(), the parse_gre_header() is called, and the
> iptunnel_pull_header() is called to pull the skb at the end of
> the parse_gre_header(). Unfortunately, the ipgre_err still needs
> the skb->data points the ip header following the icmp layer,
> and those ip addresses in ip header will be used to look up
> tunnel by ip_tunnel_lookup().
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Conditional pulling of headers based upon caller context leads to
impossible to maintain code.

Please find another way to fix this.
