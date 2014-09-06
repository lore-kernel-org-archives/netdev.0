From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ip: support of usec rtt in tcp_metrics
Date: Fri, 05 Sep 2014 17:22:58 -0700
Message-ID: <1409962978.26422.150.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409961244.26422.142.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140905170222.1599ad33@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53276 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIFAW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:22:59 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so1045899pdb.25
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 17:22:59 -0700 (PDT)
In-Reply-To: <20140905170222.1599ad33@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-05 at 17:02 -0700, Stephen Hemminger wrote:
> On Fri, 05 Sep 2014 16:54:04 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > +			if (i != TCP_METRIC_RTT &&
> > +			    i != TCP_METRIC_RTT_US &&
> > +			    i != TCP_METRIC_RTTVAR &&
> > +			    i != TCP_METRIC_RTTVAR_US) {
> > +				if (metric_name[i])
> > +					fprintf(fp, " %s ", metric_name[i]);
> > +				else
> > +					fprintf(fp, " metric_%d ", i);
> 
> Why not put new metrics in metric_name array? and make the check something like:
> 
> 			if (i < ARRAY_SIZE(metric_name) && metric_name[i])
> 				fprintf(fp, " %s ", metric_name[i]);
> 			else
> 				fprintf(fp, " metric_%d ", i)
> 
> This makes it future proof, and gets rid of the silly test.


Because for compatibility reasons, kernel gives all values,
we want to output one of them, the most accurate one.
