From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: ignore TIMESTAMP, RXQ_OVFL, WIFI_STATUS
 in sock_cmsg_send
Date: Fri, 13 May 2016 02:03:56 -0400 (EDT)
Message-ID: <20160513.020356.2040257607864696950.davem@davemloft.net>
References: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maze@google.com,
	willemb@google.com, soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbcEMGD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 02:03:59 -0400
In-Reply-To: <1463114830-32751-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Fri, 13 May 2016 00:47:10 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> SO_TIMESTAMP(NS), RXQ_OVFL, and WIFI_STATUS can be returned as
> receive-side control messages from recvmsg(). Although invalid,
> some applications may reflect those receive-side control messages
> back to sendmsg(). Since socket-level control messages were being
> ignored in ipv4 and ipv6, such applications would not get an error.
> 
> 24025c4 (ipv4: process socket-level control messages in IPv4) and
> ad1e46 (ipv6: process socket-level control messages in IPv6) add
> support for socket-level control messages in ipv4 and ipv6 on
> sendmsg(). This results in getting -EINVAL, if the application
> passes in a message with SO_WIFI_STATUS, SO_RXQ_OVFL, SO_TIMESTAMP
> and/or SO_TIMESTAMPNS that might have been received in recvmsg().
> 
> Ignore SO_WIFI_STATUS, SO_TIMESTAMP(NS), and SO_RXQ_OVFL when
> processing socket-level control messages in send-side to remain
> backward compatible.

This patch is missing a proper Signed-Off-By: tag.

But I think this change is wrong.  Just because we silently accepted
garbage in the past doesn't mean more strict checking is invalid.

Applications blindly echoing control messages from recvmsg to sendmsg
must be fixed.
