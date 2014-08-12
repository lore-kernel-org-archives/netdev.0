From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: don't allow syn packets without timestamps to
 pass tcp_tw_recycle logic
Date: Mon, 11 Aug 2014 18:32:50 -0700
Message-ID: <1407807170.10122.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:54549 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbaHLBcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 21:32:52 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so11533208pde.23
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 18:32:52 -0700 (PDT)
In-Reply-To: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-08-12 at 02:21 +0200, Hannes Frederic Sowa wrote:
> If tw_recycle is enabled, non-timestamped SYN packets could get past
> the tw_recycle check and create a new connection. This is dangerous
> as we cannot verify that segments from an old connection won't be
> accepted by the new one in tcp_validate_incoming because of the missing
> timestamps. Note that Windows seems to have timestamps disabled by
> default. Thus this broken situation could easily arise by a Linux and
> Windows box sharing one IP address and talking to a tcp_tw_recycle
> enabled server.
> 
> We don't change the behavior regarding how many SYNs we queue up from
> non timestamping hosts (the second tcp_peer_is_proven check), because the
> second call to tcp_peer_is_proven does not use the new boolean timestamp
> argument at all because PAWS check is disabled.
> 
> Cc: Florian Westphal <fw@strlen.de>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Not sure what you try to achieve here.

tw_recycle can only be used in very controlled environment, no NAT, and
all hosts using timestamps.

If using NAT, then tw_recycle can not be used, even if all hosts are
linux boxes with timestamps enabled.
