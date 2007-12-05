From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: cassini driver skb->truesize bug
Date: Wed, 5 Dec 2007 18:30:57 +0100
Message-ID: <20071205173056.GA19264@sch.bme.hu>
References: <475561DB.7080404@balabit.hu> <1196850226.9713.33.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: panther@balabit.hu, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centaur.sch.bme.hu ([152.66.208.5]:33832 "EHLO
	centaur.sch.bme.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbXLESGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 13:06:00 -0500
Content-Disposition: inline
In-Reply-To: <1196850226.9713.33.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Dec 05, 2007 at 11:23:46AM +0100, Balazs Scheidler wrote:
> Some more investigation revealed that the cassini driver leaks the data
> portion of all RXed packets, this makes the driver completely unusable.
> 
> We've tested the following combinations:
>  * 2.6.17 (patched, but no cassini related patches)
>  * 2.6.22 Ubuntu Gutsy.
> 
> It still worked in 2.6.12 where we originally backported the driver from
> 2.6.14.
> 
> The sk_buff count in slabinfo stays normal, so the skbs are properly
> freed. I'm suspicious about all this cas_page_t wrappers.

Commit fa4f0774d7c6cccb4d1fda76b91dd8eddcb2dd6a?

I don't really see how the buffer count for a page used as a fragment gets
decreased when the skb is freed.

-- 
KOVACS Krisztian
