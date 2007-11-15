From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression
 with tbench
Date: Wed, 14 Nov 2007 17:03:25 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0711141650150.21965@schroedinger.engr.sgi.com>
References: <200711140927.39796.nickpiggin@yahoo.com.au>
 <20071114.031022.183117678.davem@davemloft.net> <20071114114844.GA13927@gondor.apana.org.au>
 <20071114.154616.46285694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, nickpiggin@yahoo.com.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:34833 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753861AbXKOBDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 20:03:49 -0500
In-Reply-To: <20071114.154616.46285694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007, David Miller wrote:

> > As a result, we may allocate more than a page of data in the
> > non-TSO case when exactly one page is desired.

Well this is likely the result of the SLUB regression. If you allocate an 
order 1 page then the zone locks need to be taken. SLAB queues the a 
couple of higher order pages and can so serve a couple of requests without 
going into the page allocator whereas SLUB has to go directly to the page 
allocator for allocate and free. I guess that needs fixing in the page 
allocator. Or do I need to add a mechanism to buffer higher order page 
allcoations to SLUB?


