From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v6 4/5] vxlan: add ipv6 support
Date: Mon, 29 Apr 2013 11:52:14 -0400 (EDT)
Message-ID: <20130429.115214.930181179286504457.davem@davemloft.net>
References: <1366782874-18700-1-git-send-email-amwang@redhat.com>
	<1366782874-18700-5-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756979Ab3D2PwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:52:17 -0400
In-Reply-To: <1366782874-18700-5-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 24 Apr 2013 13:54:33 +0800

> +	rc = sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
> +	if (rc < 0) {
> +		pr_debug("UDP socket create failed\n");
> +		return rc;
> +	}

You have to fall back to creating and using an ipv4 socket if making
the ipv6 one fails.

IPV6 being enabled does not mean it is guaranteed the one can
successfully create ipv6 sockets.

You also must handle /proc/sys/net/ipv6/conf/${DEV}/disable_ipv6
correctly as far as this stuff goes as well.
