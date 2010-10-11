From: Andrew Vagin <avagin@gmail.com>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Mon, 11 Oct 2010 20:19:19 +0400
Message-ID: <4CB33907.5060803@gmail.com>
References: <1286810413-30238-1-git-send-email-avagin@openvz.org>	<4CB32FDB.4090001@msgid.tls.msk.ru>	<1286812009.2737.30.camel@edumazet-laptop> <20101011.085952.193718228.davem@davemloft.net>
Reply-To: avagin@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mjt@tls.msk.ru, avagin@openvz.org,
	stable@kernel.org, netdev@vger.kernel.org, krkumar2@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17746 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755105Ab0JKQWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 12:22:45 -0400
In-Reply-To: <20101011.085952.193718228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 10/11/2010 07:59 PM, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Mon, 11 Oct 2010 17:46:49 +0200
>
>> This patch was an optimization, not a bug fix.
> Right, this has no business going into 2.6.32-stable at all.
This is bug fix. Now nobody drops dst in case gso and veth, because the 
commit 60df914e295a21a223e43a7ee01e0c73c64dd111 deletes skb_dst_drop 
from the veth.c. We should commit my patch or revert commit 60df914e.

We have two bug reports:

http://www.spinics.net/lists/netdev/msg142104.html

http://bugzilla.openvz.org/show_bug.cgi?id=1634

Taylan verified that the patch really fix his bug.
