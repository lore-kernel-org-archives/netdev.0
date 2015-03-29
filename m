From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Sun, 29 Mar 2015 13:37:07 -0700 (PDT)
Message-ID: <20150329.133707.1244143029987516480.davem@davemloft.net>
References: <1427448262-7231-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vasily.isaenko@oracle.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbbC2U2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 16:28:23 -0400
In-Reply-To: <1427448262-7231-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Fri, 27 Mar 2015 12:24:22 +0300

> tcp_v6_fill_cb() will be called twice if socket's state changes from
> TCP_TIME_WAIT to TCP_LISTEN. That can result in control buffer data
> corruption because in the second tcp_v6_fill_cb() call it's not copying
> IP6CB(skb) anymore, but 'seq', 'end_seq', etc., so we can get weird and
> unpredictable results. Performance loss of up to 1200% has been observed
> in LTP/vxlan03 test.
> 
> This can be fixed by copying inet6_skb_parm to the beginning of 'cb'
> only if xfrm6_policy_check() and tcp_v6_fill_cb() are going to be
> called again.
> 
> Fixes: 2dc49d1680b53 ("tcp6: don't move IP6CB before xfrm6_policy_check()")
> 
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
