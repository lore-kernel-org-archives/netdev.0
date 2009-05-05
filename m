From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: Re: [PATCH 2.6.30-rc5] ehea: fix invalid pointer access
Date: Tue, 5 May 2009 13:19:05 +0200
Message-ID: <200905051319.05806.hannes.hering@linux.vnet.ibm.com>
References: <200905041802.30527.hannes.hering@linux.vnet.ibm.com> <25628.1241514687@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, themann@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	raisch@de.ibm.com, ossrosch@linux.vnet.ibm.com,
	linuxppc-dev@ozlabs.org, ossthema@de.ibm.com, osstklei@de.ibm.com
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:47955 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403AbZEELTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 07:19:11 -0400
In-Reply-To: <25628.1241514687@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 May 2009 11:11:27 David Howells wrote:
> Hannes Hering <hannes.hering@linux.vnet.ibm.com> wrote:
> 
> >  	pref = skb_array[x];
> > -	prefetchw(pref);
> > -	prefetchw(pref + EHEA_CACHE_LINE);
> > +	if (pref) {
> > +		prefetchw(pref);
> > +		prefetchw(pref + EHEA_CACHE_LINE);
> 
> Ummm...  Is prefetch() or prefetchw() faulting?
> 
> David
Hi David,

this is an ehea driver problem, which is occuring when the receive queue runs
empty. The faulting code is more specifically the following line:

	pref = (skb_array[x]->data);

Here the access to the struct element data would cause an exception.We could
have made the if block a little smaller.

Regards

Hannes
