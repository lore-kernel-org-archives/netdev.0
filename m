From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] iproute2: add support for tcp_metrics
Date: Tue, 2 Oct 2012 17:26:33 -0700
Message-ID: <20121002172633.2be06886@nehalam.linuxnetplumber.net>
References: <1349210716-25509-1-git-send-email-ja@ssi.bg>
	<1349211876.12401.1101.camel@edumazet-glaptop>
	<1349213229.12401.1130.camel@edumazet-glaptop>
	<alpine.LFD.2.00.1210030302320.25856@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41259 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932930Ab2JCA1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 20:27:09 -0400
In-Reply-To: <alpine.LFD.2.00.1210030302320.25856@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Oct 2012 03:21:08 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	Something like this in process_msg?:
> 
> case TCP_METRIC_RTT:
> 	fprintf(fp, "%lluus",
> 		((__u64) val * 1000) >> 3);
> 	break;
> case TCP_METRIC_RTTVAR:
> 	fprintf(fp, "%lluus",
> 		((__u64) val * 1000) >> 2);
> 	break;
> 
> 	And may be variant without __u64 should be fine?

Remember u64 is not always same as unsigned long long.
One safe way of handling this is:

#include <inttypes.h>
...
 
 case TCP_METRIC_RTT:
	fprintf(fp, "%"PRIu64"us",
 		((__u64) val * 1000) >> 3);
 	break;
 case TCP_METRIC_RTTVAR:
 	fprintf(fp, "%"PRIu64"us",
 		((__u64) val * 1000) >> 2);
 	break;

Also make sure metrics work independent of kernel HZ.
