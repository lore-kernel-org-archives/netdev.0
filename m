From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 15:19:31 -0400
Message-ID: <20070501191931.GF1751@kvack.org>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org> <20070501174126.GA7577@2ka.mipt.ru> <20070501175340.GD1751@kvack.org> <463780D8.2080105@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:38017 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161809AbXEATTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 15:19:44 -0400
Content-Disposition: inline
In-Reply-To: <463780D8.2080105@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 02:03:04PM -0400, John Heffner wrote:
> Actually, you cannot get in this situation by loss or reordering of 
> packets, only be corruption of state on one side.  It sends the FIN, 
> which effectively increases the sequence number by one.  However, all 
> later segments it sends have an old lower sequence number, which are now 
> out of window.

Okay, I missed the other packets with a FIN later on in the storm.  What is 
different about them is that they get sent with different timestamps than 
the acks being thrown about.  Perhaps narrowly looking at the lack of FIN 
is wrong -- I'll try instrumenting what the PAWS code is doing on both 
sides as that is probably what short circuits an ACK into being sent.

> Being liberal in what you accept is good to a point, but sometimes you 
> have to draw the line.

True.  Still, both sides are doing completely the wrong thing in this case, 
and I'd like to get an idea of the best way to prevent the ACK storm from 
happenning.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <zyntrop@kvack.org>.
