From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] Proportional Rate Reduction for TCP.
Date: Wed, 24 Aug 2011 19:43:24 -0700 (PDT)
Message-ID: <20110824.194324.1605618957508979830.davem@davemloft.net>
References: <1313803779-6221-1-git-send-email-nanditad@google.com>
	<1313994117-7374-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, mattmathis@google.com,
	ycheng@google.com
To: nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab1HYCn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 22:43:27 -0400
In-Reply-To: <1313994117-7374-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nandita Dukkipati <nanditad@google.com>
Date: Sun, 21 Aug 2011 23:21:57 -0700

> This patch implements Proportional Rate Reduction (PRR) for TCP.
> PRR is an algorithm that determines TCP's sending rate in fast
> recovery. PRR avoids excessive window reductions and aims for
> the actual congestion window size at the end of recovery to be as
> close as possible to the window determined by the congestion control
> algorithm. PRR also improves accuracy of the amount of data sent
> during loss recovery.
> 
> The patch implements the recommended flavor of PRR called PRR-SSRB
> (Proportional rate reduction with slow start reduction bound) and
> replaces the existing rate halving algorithm. PRR improves upon the
> existing Linux fast recovery under a number of conditions including:
>   1) burst losses where the losses implicitly reduce the amount of
> outstanding data (pipe) below the ssthresh value selected by the
> congestion control algorithm and,
>   2) losses near the end of short flows where application runs out of
> data to send.
> 
> As an example, with the existing rate halving implementation a single
> loss event can cause a connection carrying short Web transactions to
> go into the slow start mode after the recovery. This is because during
> recovery Linux pulls the congestion window down to packets_in_flight+1
> on every ACK. A short Web response often runs out of new data to send
> and its pipe reduces to zero by the end of recovery when all its packets
> are drained from the network. Subsequent HTTP responses using the same
> connection will have to slow start to raise cwnd to ssthresh. PRR on
> the other hand aims for the cwnd to be as close as possible to ssthresh
> by the end of recovery.
> 
> A description of PRR and a discussion of its performance can be found at
> the following links:
> - IETF Draft:
>     http://tools.ietf.org/html/draft-mathis-tcpm-proportional-rate-reduction-01
> - IETF Slides:
>     http://www.ietf.org/proceedings/80/slides/tcpm-6.pdf
>     http://tools.ietf.org/agenda/81/slides/tcpm-2.pdf
> - Paper to appear in Internet Measurements Conference (IMC) 2011:
>     Improving TCP Loss Recovery
>     Nandita Dukkipati, Matt Mathis, Yuchung Cheng
> 
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>

Applied.
