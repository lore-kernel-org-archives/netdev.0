From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH]  flow_cache_flush soft lockup with heavy ipsec traffic
Date: Wed, 9 Nov 2011 14:43:48 +0100
Message-ID: <20111109134348.GD10138@secunet.com>
References: <4EBA7038.4050702@mt.lv>
 <1320844564.3916.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maris Paupe <marisp@mt.lv>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:40274 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021Ab1KINny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 08:43:54 -0500
Content-Disposition: inline
In-Reply-To: <1320844564.3916.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2011 at 02:16:04PM +0100, Eric Dumazet wrote:
> 
> Sorry, I dont understand your patch.
> 
> BH are disabled by the spin_lock_bh() call.
> 
> Once flow_cache_entry are in garbage list, nothing but garbage collector
> can access them. I see no possible deadlock. Or there is a bug somewhere
> and your patch avoid it.
> 
> Whole point of using a work queue to perform garbage collect was to not
> hold BH too long (allowing sotirq to process incoming packets), so you
> basically remove what was done in commit 8e4795605d.
> 

I guess this tries to address a problem that was already discussed here:

http://patchwork.ozlabs.org/patch/116457/
