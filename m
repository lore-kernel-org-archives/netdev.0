From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 9 Aug 2006 10:53:18 +0200
Message-ID: <200608091053.18861.dada1@cosmosbay.com>
References: <200608080711.06788.ak@suse.de> <200608090224.04158.ak@suse.de> <44D9984D.9040304@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, David Miller <davem@davemloft.net>,
	akepner@sgi.com, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:9406 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S965103AbWHIIxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 04:53:19 -0400
To: Kirill Korotaev <dev@sw.ru>
In-Reply-To: <44D9984D.9040304@sw.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 August 2006 10:09, Kirill Korotaev wrote:
> >>2) for cases where we haven't implemented dynamic
> >>   table growth, specifying a proper limit argument
> >>   to the hash table allocation is a sufficient
> >>   solution for the time being
> >
> > Agreed, just we don't know what the proper limits are.
> >
> > I guess it would need someone running quite a lot of benchmarks.
> > Anyone volunteering? @)
>
> In my original post I noted how it is quite easy to consume
> the whole 1Gb of RAM on i686 PC (and it's only 4,194,304 entries)
> it looks like with more IP addresses it is not that hard to
> consume much more memory.

If MAX_ORDER = 11, we have a max hash table of 8 MB : 2097152 slots
But even 2097152 dst need 139810 pages (560 MB of low mem), so 16 times 
needs... too much ram.

Probably a test like this is necessary :

if (ip_rt_max_size > (nr_kernel_pages/8))
    ip_rt_max_size = (nr_kernel_pages/8);

Eric
