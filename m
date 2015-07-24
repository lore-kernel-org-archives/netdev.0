From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix recv with flags MSG_WAITALL | MSG_PEEK
Date: Fri, 24 Jul 2015 19:05:56 +0200
Message-ID: <1437757556.20182.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150724161925.GA12489@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Enrico Scholz <rh-bugzilla@ensc.de>,
	Dan Searle <dan@censornet.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37637 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbbGXRF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 13:05:59 -0400
Received: by wibud3 with SMTP id ud3so36173509wib.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 10:05:58 -0700 (PDT)
In-Reply-To: <20150724161925.GA12489@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-24 at 18:19 +0200, Sabrina Dubroca wrote:
> Currently, tcp_recvmsg enters a busy loop in sk_wait_data if called
> with flags = MSG_WAITALL | MSG_PEEK.
> 
> sk_wait_data waits for sk_receive_queue not empty, but in this case,
> the receive queue is not empty, but does not contain any skb that we
> can use.
> 
> Add a "last skb seen on receive queue" argument to sk_wait_data, so
> that it sleeps until the receive queue has new skbs.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=99461
> Link: https://sourceware.org/bugzilla/show_bug.cgi?id=18493
> Link: https://bugzilla.redhat.com/show_bug.cgi?id=1205258
> Reported-by: Enrico Scholz <rh-bugzilla@ensc.de>
> Reported-by: Dan Searle <dan@censornet.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---

Very nice !

Acked-by: Eric Dumazet <edumazet@google.com>
