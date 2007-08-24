From: John Heffner <jheffner@psc.edu>
Subject: Re: Problem with implementation of TCP_DEFER_ACCEPT?
Date: Fri, 24 Aug 2007 12:09:23 -0400
Message-ID: <46CF02B3.6020101@psc.edu>
References: <1187914105.26866.41.camel@bagoas.tjworld.net>	 <20070824071530.GB26447@xi.wantstofly.org>	 <20070824084048.GA8346@ms2.inr.ac.ru> <1187947887.6976.18.camel@bagoas.tjworld.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: TJ <linux@tjworld.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:62193 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526AbXHXQKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 12:10:16 -0400
In-Reply-To: <1187947887.6976.18.camel@bagoas.tjworld.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TJ wrote:
> Right now Juniper are claiming the issue that brought this to the
> surface (the bug linked to in my original post) is a problem with the
> implementation of TCP_DEFER_ACCEPT.
> 
> My position so far is that the Juniper DX OS is not following the HTTP
> standard because it doesn't send a request with the connection, and as I
> read the end of section 1.4 of RFC2616, an HTTP connection should be
> accompanied by a request.
> 
> Can anyone confirm my interpretation or provide references to firm it
> up, or refute it?

You can think of TCP_DEFER_ACCEPT as an implicit application close() 
after a certain timeout, when not receiving a request.  All HTTP servers 
do this anyway (though I think technically they're supposed to send a 
408 Request Timeout error it seems many do not).  It's a very valid 
question for Juniper as to why their box is failing to fill requests 
when its back-end connection has gone away, instead of re-establishing 
the connection and filling the request.

   -John
