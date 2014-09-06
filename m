From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: support of usec rtt in tcp_metrics
Date: Fri, 5 Sep 2014 17:02:22 -0700
Message-ID: <20140905170222.1599ad33@urahara>
References: <1409961244.26422.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:42633 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbaIFAC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:02:26 -0400
Received: by mail-pd0-f170.google.com with SMTP id r10so16756948pdi.29
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 17:02:26 -0700 (PDT)
In-Reply-To: <1409961244.26422.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Sep 2014 16:54:04 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> +			if (i != TCP_METRIC_RTT &&
> +			    i != TCP_METRIC_RTT_US &&
> +			    i != TCP_METRIC_RTTVAR &&
> +			    i != TCP_METRIC_RTTVAR_US) {
> +				if (metric_name[i])
> +					fprintf(fp, " %s ", metric_name[i]);
> +				else
> +					fprintf(fp, " metric_%d ", i);

Why not put new metrics in metric_name array? and make the check something like:

			if (i < ARRAY_SIZE(metric_name) && metric_name[i])
				fprintf(fp, " %s ", metric_name[i]);
			else
				fprintf(fp, " metric_%d ", i)

This makes it future proof, and gets rid of the silly test.
