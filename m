From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: When TCP keepalives tuned shorter than retransmission timeouts
Date: Tue, 26 Nov 2013 08:20:22 -0800
Message-ID: <1385482822.5352.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <4b6029b3-55da-441a-9550-0fed3b49506a@default>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:39201 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757253Ab3KZQUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 11:20:23 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so8209303pbb.8
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 08:20:23 -0800 (PST)
In-Reply-To: <4b6029b3-55da-441a-9550-0fed3b49506a@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-26 at 07:51 -0800, Venkat Venkatsubra wrote:
> Some of our customers have tcp socket level options set to:
> TCP_KEEPIDLE 60
> TCP_KEEPINTVL 6 
> TCP_KEEPCNT 10
> 
> And when the peer is dead they expect the connection to timeout in 2 minutes instead of the
> 15 minutes from retransmission timeouts.
> (We know the tunables are set very low.)

Then change max number of retransmits : tcp_retries2 ?

Keepalive timer is not a way to defeat TCP exponential backoff.

Its really there to send probes when a session is idle.
