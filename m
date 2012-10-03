From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] iproute2: add support for tcp_metrics
Date: Wed, 3 Oct 2012 03:21:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210030302320.25856@ja.ssi.bg>
References: <1349210716-25509-1-git-send-email-ja@ssi.bg>  <1349211876.12401.1101.camel@edumazet-glaptop> <1349213229.12401.1130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46686 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932810Ab2JCAQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 20:16:01 -0400
In-Reply-To: <1349213229.12401.1130.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 2 Oct 2012, Eric Dumazet wrote:

> By the way, it seems kernel exports scaled srtt by 8, and rttvar by 4.
> 
> And tcp_get_info() correctly exports us, not ms.
> 
> info->tcpi_rtt = jiffies_to_usecs(tp->srtt)>>3;
> info->tcpi_rttvar = jiffies_to_usecs(tp->mdev)>>2;
> 
> IMHO we should use same unit than TCP_INFO (us for these values)

	Something like this in process_msg?:

case TCP_METRIC_RTT:
	fprintf(fp, "%lluus",
		((__u64) val * 1000) >> 3);
	break;
case TCP_METRIC_RTTVAR:
	fprintf(fp, "%lluus",
		((__u64) val * 1000) >> 2);
	break;

	And may be variant without __u64 should be fine?

Regards

--
Julian Anastasov <ja@ssi.bg>
