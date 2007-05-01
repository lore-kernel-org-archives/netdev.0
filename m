From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 01 May 2007 14:03:04 -0400
Message-ID: <463780D8.2080105@psc.edu>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org> <20070501174126.GA7577@2ka.mipt.ru> <20070501175340.GD1751@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:61350 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255AbXEASIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 14:08:13 -0400
In-Reply-To: <20070501175340.GD1751@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise wrote:
> On Tue, May 01, 2007 at 09:41:28PM +0400, Evgeniy Polyakov wrote:
>> Hmm, 2.2 machine in your test seems to behave incorrectly:
> 
> I am aware of that.  However, I think that the loss of certain packets and 
> reordering can result in the same behaviour.  What's more, is that this 
> behaviour can occur in real deployed systems.  "Be strict in what you send 
> and liberal in what you accept."  Both systems should be fixed, which is 
> what I'm trying to do.

Actually, you cannot get in this situation by loss or reordering of 
packets, only be corruption of state on one side.  It sends the FIN, 
which effectively increases the sequence number by one.  However, all 
later segments it sends have an old lower sequence number, which are now 
out of window.

Being liberal in what you accept is good to a point, but sometimes you 
have to draw the line.

   -John
