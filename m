From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH v2 1/3 net-next] tcp: refactor F-RTO
Date: Wed, 20 Mar 2013 16:55:06 -0700
Message-ID: <1363823706.3333.31.camel@edumazet-glaptop>
References: <1363822380-16687-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com, ilpo.jarvinen@cs.helsinki.fi,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:60987 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430Ab3CUABJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 20:01:09 -0400
Received: by mail-pb0-f49.google.com with SMTP id xa12so1767527pbc.36
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 17:01:09 -0700 (PDT)
In-Reply-To: <1363822380-16687-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 16:32 -0700, Yuchung Cheng wrote:
> The patch series refactor the F-RTO feature (RFC4138/5682).
> 
> This is to simplify the loss recovery processing. Existing F-RTO
> was developed during the experimental stage (RFC4138) and has
> many experimental features.  It takes a separate code path from
> the traditional timeout processing by overloading CA_Disorder
> instead of using CA_Loss state. This complicates CA_Disorder state
> handling because it's also used for handling dubious ACKs and undos.
> While the algorithm in the RFC does not change the congestion control,
> the implementation intercepts congestion control in various places
> (e.g., frto_cwnd in tcp_ack()).
> 
> The new code implements newer F-RTO RFC5682 using CA_Loss processing
> path.  F-RTO becomes a small extension in the timeout processing
> and interfaces with congestion control and Eifel undo modules.
> It lets congestion control (module) determines how many to send
> independently.  F-RTO only chooses what to send in order to detect
> spurious retranmission. If timeout is found spurious it invokes
> existing Eifel undo algorithms like DSACK or TCP timestamp based
> detection.
> 
> The first patch removes all F-RTO code except the sysctl_tcp_frto is
> left for the new implementation.  Since CA_EVENT_FRTO is removed, TCP
> westwood now computes ssthresh on regular timeout CA_EVENT_LOSS event.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
