From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Mon, 19 Nov 2007 10:02:03 +0800
Message-ID: <4740EE9B.40901@cn.fujitsu.com>
References: <p73bq9tau2x.fsf@bingen.suse.de>	<20071117.160926.232024605.davem@davemloft.net>	<20071118214515.GA8161@one.firstfloor.org> <20071118.144010.236028466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:65313 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbXKSCE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2007 21:04:28 -0500
In-Reply-To: <20071118.144010.236028466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller said the following on 2007-11-19 6:40:
> We could defer the increment until we check the checksum,
> but that is likely to break even more things because people
> (as Wang Chen did initially) will send a packet to some
> port with an app that doesn't eat the packets, and expect the
> InDatagrams counter to increase once the stack eats the packet.

As Herbert referred, RFC1213 says that udpInDatagrams records
"The total number of UDP datagrams delivered to UDP users."

So if "udp_queue_rcv_skb() doing sucessfully" means "a UDP
datagrams delivered to UDP users", the InDatagrams should be
increased in udp_queue_rcv_skb().
Otherwise it should be increased until the UDP datagrams is
actually delivered to UDP users.

