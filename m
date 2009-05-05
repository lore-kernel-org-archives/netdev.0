From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2.6.30-rc5] ehea: fix invalid pointer access
Date: Tue, 05 May 2009 10:11:27 +0100
Message-ID: <25628.1241514687@redhat.com>
References: <200905041802.30527.hannes.hering@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, David Miller <davem@davemloft.net>,
	themann@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, raisch@de.ibm.com,
	ossrosch@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org,
	ossthema@de.ibm.com, osstklei@de.ibm.com
To: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42892 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748AbZEEJq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 05:46:26 -0400
In-Reply-To: <200905041802.30527.hannes.hering@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Hering <hannes.hering@linux.vnet.ibm.com> wrote:

>  	pref = skb_array[x];
> -	prefetchw(pref);
> -	prefetchw(pref + EHEA_CACHE_LINE);
> +	if (pref) {
> +		prefetchw(pref);
> +		prefetchw(pref + EHEA_CACHE_LINE);

Ummm...  Is prefetch() or prefetchw() faulting?

David
