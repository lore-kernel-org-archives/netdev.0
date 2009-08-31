From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] [v3] Revert Backoff on ICMP destination unreachable
Date: Sun, 30 Aug 2009 21:56:29 -0700 (PDT)
Message-ID: <20090830.215629.259434175.davem@davemloft.net>
References: <4A950B76.1070002@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60960
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752475AbZHaE4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 00:56:15 -0400
In-Reply-To: <4A950B76.1070002@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Wed, 26 Aug 2009 12:16:22 +0200

> This series of patches implements the TCP improvement of the Internet Draft
> "Make TCP more Robust to Long Connectivity Disruptions"
> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
> 
> Exponential backoff is TCP's standard behaviour during long connectivity
> disruptions, which is a countermeasure against network congestion.
> If congestion can be excluded as the reason for RTO retransmission loss,
> backoff is not desirable, as it yields longer TCP recovery times, when
> the communication path is repaired shortly after an unsuccessful
> retransmission probe.
> 
> 1) This patch renames the skb in tcp_v4_err() in preparation for patch 2.
> 2) Contains the main reversion logic.
>    Reintroduces tcp_bound_rto() and __tcp_set_rto()
> 3) This patch modifies the interpretation of the tcp_retries{1,2} sysctls.
>    It became necessary because with patch2 the assumption that the number
>    of retransmits corresponds to an specific timeout value is not accurate
>    anymore. With this patch tcp_retries{1,2} specifies a timeout value,
>    equivalent to the time a connection with an rto value of MIN_RTO (200ms)
>    would need to retransmit N segments. IOW: The meaning (in sense of time)
>    is mostly preserved, but the actual connection timeout does not depend
>    on the calculated rto of the connection, anymore.
> 
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

Ilpo can you please review this new version of Damian's changes?

Thanks.
