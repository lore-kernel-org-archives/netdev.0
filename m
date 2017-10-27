From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipip: only increase err_count for some certain
 type icmp in ipip_err
Date: Fri, 27 Oct 2017 23:47:22 +0900 (KST)
Message-ID: <20171027.234722.793819361242345327.davem@davemloft.net>
References: <335a3f6cef850b848452e6f1258039472dafc093.1509016796.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        pshelar@nicira.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdJ0Or0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:26 -0400
In-Reply-To: <335a3f6cef850b848452e6f1258039472dafc093.1509016796.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 26 Oct 2017 19:19:56 +0800

> t->err_count is used to count the link failure on tunnel and an err
> will be reported to user socket in tx path if t->err_count is not 0.
> udp socket could even return EHOSTUNREACH to users.
> 
> Since commit fd58156e456d ("IPIP: Use ip-tunneling code.") removed
> the 'switch check' for icmp type in ipip_err(), err_count would be
> increased by the icmp packet with ICMP_EXC_FRAGTIME code. an link
> failure would be reported out due to this.
> 
> In Jianlin's case, when receiving ICMP_EXC_FRAGTIME a icmp packet,
> udp netperf failed with the err:
>   send_data: data send error: No route to host (errno 113)
> 
> We expect this error reported from tunnel to socket when receiving
> some certain type icmp, but not ICMP_EXC_FRAGTIME, ICMP_SR_FAILED
> or ICMP_PARAMETERPROB ones.
> 
> This patch is to bring 'switch check' for icmp type back to ipip_err
> so that it only reports link failure for the right type icmp, just as
> in ipgre_err() and ipip6_err().
> 
> Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Good catch, I have no idea why that logic was removed.  Maybe the
author didn't see the err_count side effect and it's implications.

Applied and queued up for -stable.
