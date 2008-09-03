From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] bridge: STP timer management range checking
Date: Tue, 02 Sep 2008 17:28:01 -0700 (PDT)
Message-ID: <20080902.172801.12895688.davem@davemloft.net>
References: <a08621850808310151o143845h195a8658d02270d9@mail.gmail.com>
	<20080831100537.6929c51e@extreme>
	<20080831104309.780cc01f@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dusanc@gmail.com, romieu@fr.zoreil.com, hancockr@shaw.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60533
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754151AbYICA2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:28:07 -0400
In-Reply-To: <20080831104309.780cc01f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 31 Aug 2008 10:43:09 -0700

> The Spanning Tree Protocol timers need to be set within certain boundaries
> to keep the internal protocol engine working, and to be interoperable.
> This patch restricts changes to those timers to the values defined in IEEE 802.1D
> specification.
> 
> The only exception to the standards are:
>   * if STP is disabled allow forwarding delay to be turned off
>   * allow wider range of ageing timer since this isn't directly part of
>     STP, and setting it to zero allows for non-remembering bridge.
> 
> Warning: this may cause user backlash since apparently working but standards
>   conforming configurations will get configuration errors that they didn't
>   see before.

I don't think we can really add these kinds of restrictions wholesale
like this.

And the user is reporting that using brctl to turn off STP doesn't
appear to actually turn off STP and thus fix all of the crazy
ksoftirqd high cpu load problems.

So what we need to do is resolve the user configuration issue that is
causing this problem to begin with.
