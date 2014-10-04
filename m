From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bridge IGMP snooping question
Date: Sat, 4 Oct 2014 12:05:37 +0800
Message-ID: <20141004040537.GA8405@gondor.apana.org.au>
References: <542D0911.3040402@rockbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Martitz <kugel@rockbox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37220 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaJDEFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 00:05:40 -0400
Content-Disposition: inline
In-Reply-To: <542D0911.3040402@rockbox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2014 at 10:13:05AM +0200, Thomas Martitz wrote:
> Hello Linux folks,
> 
> I have one question regarding IGMP snooping on bridges, specifically
> about leaving multicast groups.
> 
> br_multicast_leave_group() has this check early on:
> 
> if (!netif_running(br->dev) ||
>         (port && port->state == BR_STATE_DISABLED) ||
>         timer_pending(&querier->timer)) /* <- THIS */
>                goto out;
> 
> I'm wondering why the bridge code prevents group leaves if if the
> querier timer is pending. From my understanding the timer acts as an
> indication whether the local system is the network's querier or not
> (if pending then another router is querier). Therefore this check
> prevents to leave groups if there is another querier.
> 
> I'm wondering what's the rationale for this, if any. It seems to be
> that the decision whether an attached client gets mc forwarded is
> independent on whether the local system is querier or not. Git log
> does not reveal the answer as this check is there from the
> beginning.
> 
> PS: This behavior conflicts with something I'm working.

You can't just leave a group because you received a single
leave message.  There may be another group member still listening
on that port.

To make sure no listeners are left a query message must be sent.
If there is another querier on the network then they are meant to
send such a query message which means that all we have to do is
passively wait for the timeout to expire.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
