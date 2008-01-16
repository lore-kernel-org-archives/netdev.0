From: David Miller <davem@davemloft.net>
Subject: Re: Not understand some in htb_do_events function
Date: Tue, 15 Jan 2008 21:07:29 -0800 (PST)
Message-ID: <20080115.210729.128392129.davem@davemloft.net>
References: <478C87D9.1010305@trash.net>
	<478CA02A.1070308@cdi.cz>
	<478CD741.7040004@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, slavon@bigtelecom.ru, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57727
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751248AbYAPFHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 00:07:30 -0500
In-Reply-To: <478CD741.7040004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 15 Jan 2008 16:54:41 +0100

> Martin Devera wrote:
> > to drain extra events asap. It the time of writing I was not able to
> > come with better solution and there were more bugs related to this
> > part of code than now.
> 
> So this was meant to protect against endless loops?

I think, as Martin tried to explain further, it's trying
to avoid cases where the amount of work is extremely large.

Heuristics like this are by definition going to hit cases
where the value chosen is wrong or inappropriate.  On fast
cpus maybe a value of 50000 instead of 500 would work "best"

Therefore I would suggest removing the limit altogether for now and in
the long term work on whatever deficiencies in the algorithm make this
expensive enough to warrant limits in the first place.
