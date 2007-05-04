From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [SCTP] Set assoc_id correctly during INIT
 collision.
Date: Fri, 04 May 2007 13:55:45 -0700 (PDT)
Message-ID: <20070504.135545.77403988.davem@davemloft.net>
References: <20070504.133539.68042018.davem@davemloft.net>
	<11783114581224-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32901
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031567AbXEDUzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 16:55:43 -0400
In-Reply-To: <11783114581224-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  4 May 2007 16:44:18 -0400

> During the INIT/COOKIE-ACK collision cases, it's possible to get
> into a situation where the association id is not yet set at the time
> of the user event generation.  As a result, user events have an
> association id set to 0 which will confuse applications.
> 
> This happens if we hit case B of duplicate cookie processing.
> In the particular example found and provided by Oscar Isaula
> <Oscar.Isaula@motorola.com>, flow looks like this:
> A				B
> ---- INIT------->  (lost)
> 	    <---------INIT------
> ---- INIT-ACK--->
> 	    <------ Cookie ECHO
> 
> When the Cookie Echo is received, we end up trying to update the
> association that was created on A as a result of the (lost) INIT,
> but that association doesn't have the ID set yet.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks for fixing this up.
