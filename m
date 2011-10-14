From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skbuff: update sk truesize in pskb_expand_head
Date: Fri, 14 Oct 2011 03:48:22 -0400 (EDT)
Message-ID: <20111014.034822.2255593021765068562.davem@davemloft.net>
References: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755479Ab1JNHsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 03:48:24 -0400
In-Reply-To: <1318577970-19566-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 14 Oct 2011 15:39:30 +0800

> when pskb_expand_head reallocates header of &sk_buff, the sk
> truesize should be updated simultaneously
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

I know you did not test this patch at all.

You can't modify the truesize because packets passed to this routine
are often attached to a socket, thus if you change the truesize the
socket memory accouting will be adjusted incorrectly later when the
SKB is freed up.

Most SKB modifying functions have to operate with this restriction.
