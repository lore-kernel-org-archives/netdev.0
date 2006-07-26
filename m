From: John Heffner <jheffner@psc.edu>
Subject: Re: MTU probing bug?
Date: Tue, 25 Jul 2006 21:53:01 -0400
Message-ID: <44C6CAFD.8090107@psc.edu>
References: <20060725.001744.26930215.davem@davemloft.net>	<44C62316.9080501@psc.edu> <20060725.144225.67885911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:15843 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1030352AbWGZBxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 21:53:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060725.144225.67885911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> I find it interesting that black hole detection is handled
> different from a normal probe failure.  I guess here we are
> dealing with a more significant failure, so we should start
> at the thing which is most guarenteed to work.

Black hole detection is substantially different than probe failure. 
It's an indication that your current effective MTU is too large, and 
must be reduced.  A black hole basically means that your current path 
information is no good, either because your initial values are wrong, or 
the path changed.  So, you really want to reset everything to 
conservative values.  After a failed probe, your effective MTU is still 
fine, you've just gotten some additional information about the path 
(that it doesn't support the higher MTU).

   -John
