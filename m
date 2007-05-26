From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] Update htb rate when stats are polled.
Date: Sat, 26 May 2007 09:58:36 +0200
Message-ID: <4657E8AC.4080505@trash.net>
References: <Pine.LNX.4.63.0705250923210.27351@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52087 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbXEZH6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 03:58:49 -0400
In-Reply-To: <Pine.LNX.4.63.0705250923210.27351@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ranjit Manomohan wrote:
> Currently the HTB rate for a class is update very slowly (once
> every 16 seconds). This patch updates the rate whenever the stats
> are requested from user space. This enables more accurate rate
> monitoring.
> 
> +/* Update packet/byte rate for a class. */
> +static void calc_rate(struct htb_class *cl)
> +{
> +    unsigned long now = jiffies;
> +    if (time_after(now, (cl->rate_est_when + HZ))) {
> +    unsigned int elapsed_secs =
> +            (now - cl->rate_est_when)/HZ;
> +        cl->sum_bytes /= elapsed_secs;
> +        cl->sum_packets /= elapsed_secs;
> +        RT_GEN (cl->sum_bytes,cl->rate_bytes);
> +        RT_GEN (cl->sum_packets,cl->rate_packets);
> +        cl->rate_est_when = now;
> +    } else if time_before(now, cl->rate_est_when)
> +        cl->rate_est_when = now; /* Wraparound */
> +}


We have a generic rate estimator, I think we should convert HTB over
to use it and then maybe add this feature to the generic estimator.
