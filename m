From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH iproute2 1/2] tc_core: Use double in tc_core_time2tick()
Date: Tue, 09 Jun 2009 16:03:16 +0200
Message-ID: <4A2E6BA4.30002@trash.net>
References: <20090609080536.GD5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Antonio Almeida <vexwek@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <devik@cdi.cz>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63811 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbZFIODR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 10:03:17 -0400
In-Reply-To: <20090609080536.GD5237@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Change 'time' parameters of tc_core_time2tick() and tc_core_time2big()
> from unsigned to double. It is especially needed to use in
> tc_calc_rtable() for kernels with increased psched ticks resolution,
> but even without this, it looks reasonable to avoid rounding here.

I would prefer to keep using integers, which are a lot easier to
analyze for rounding errors and overflows, besides having constant
granularity.

> -unsigned tc_core_time2tick(unsigned time)
> +unsigned tc_core_time2tick(double time)
>  {
> -	return time*tick_in_usec;
> +	return time * tick_in_usec + 0.5;

ceil()?

>  }

It seems inconsistent to have the time2tick() function take a
double, but return an unsigned from tick2time(). If we're going
to change this, please keep them symetrical (you could even use
floor() in tick2time() to make it more explicit).

