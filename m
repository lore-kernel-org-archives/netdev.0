From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC] myri10ge: small rx_done refactoring
Date: Wed, 23 Mar 2011 11:21:05 -0400
Message-ID: <4D8A0FE1.1040500@myri.com>
References: <20110323124939.GA7834@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brice Goglin <brice@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:33268 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932963Ab1CWPVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 11:21:10 -0400
Received: by qyk7 with SMTP id 7so4579684qyk.19
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 08:21:09 -0700 (PDT)
In-Reply-To: <20110323124939.GA7834@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/11 08:52, Stanislaw Gruszka wrote:

> on my i686 system, what should also make myri10ge_clean_rx_done()
> being faster.

I tested this on my very old, very weak dual-core athlon64 systems.
These machines can barely achieve 10Gb/s using a 1500b MTU with LRO.
Running 35 60 second netperf tests into the machines with the stock
driver, and again with this patch applied, I see a tiny bandwidth
increase (1.4Mb/s on average) which is statistically significant
( p <  0.001). There is no statistically significant CPU load
reduction.

> +	if (len<= mgp->small_bytes) {
> +		rx =&ss->rx_small;
> +		bytes = mgp->small_bytes;
> +	} else {
> +		rx =&ss->rx_big,

Small nit:  the "," above should be a ";"

Between the small bandwidth increase, and the code size reduction,
I'm very appreciative of this patch.

Thank you,

Drew
