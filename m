From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix bug in sctp_poll for
 SOCK_SELECT_ERR_QUEUE
Date: Wed, 11 Sep 2013 16:14:01 -0400 (EDT)
Message-ID: <20130911.161401.1088919298333377389.davem@davemloft.net>
References: <1378565099-20987-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	jacob.e.keller@intel.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756310Ab3IKUOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:14:03 -0400
In-Reply-To: <1378565099-20987-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat,  7 Sep 2013 16:44:59 +0200

> If we do not add braces around ...
> 
>   mask |= POLLERR |
>           sock_flag(sk, SOCK_SELECT_ERR_QUEUE) ? POLLPRI : 0;
> 
> ... then this condition always evaluates to true as POLLERR is
> defined as 8 and binary or'd with whatever result comes out of
> sock_flag(). Hence instead of (X | Y) ? A : B, transform it into
> X | (Y ? A : B). Unfortunatelty, commit 8facd5fb73 ("net: fix
> smatch warnings inside datagram_poll") forgot about SCTP. :-(
> 
> Introduced by 7d4c04fc170 ("net: add option to enable error queue
> packets waking select").
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable.
