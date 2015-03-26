From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Thu, 26 Mar 2015 04:46:46 -0700
Message-ID: <1427370406.25985.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427358484-16402-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vasily.isaenko@oracle.com
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35778 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbbCZLqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 07:46:49 -0400
Received: by igcau2 with SMTP id au2so127062603igc.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 04:46:48 -0700 (PDT)
In-Reply-To: <1427358484-16402-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-26 at 11:28 +0300, Alexey Kodanev wrote:
> Regression from the following commit: 2dc49d1680.
> 
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
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---

Thanks Alexey !

Fixes: 2dc49d1680b53 ("tcp6: don't move IP6CB before xfrm6_policy_check()")
Acked-by: Eric Dumazet <edumazet@google.com>
