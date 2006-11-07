From: Vitaly Wool <vwool@ru.mvista.com>
Subject: Re: [PATCH/RFC] add netpoll support for gianfar
Date: Tue, 7 Nov 2006 13:25:02 +0300
Message-ID: <20061107132502.6577d65f.vwool@ru.mvista.com>
References: <20061106141958.00002c6c.vwool@ru.mvista.com>
	<D22C8326-01E3-428C-B1EE-F87B1232BDB4@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:8292 "EHLO
	buildserver.ru.mvista.com") by vger.kernel.org with ESMTP
	id S932106AbWKGK0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 05:26:05 -0500
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <D22C8326-01E3-428C-B1EE-F87B1232BDB4@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Nov 2006 15:26:33 -0600
Andy Fleming <afleming@freescale.com> wrote:
 
> You are passing extra arguments, here

Oh yes, thanks. I was out of sync here.

> 1) Do we need the disable/enable irq stuff?  It seems like we should  
> be able to either just *mask* the interrupts at the controller, or  
> rely on the locks to disable the interrupts.

I don't see how masking the ints at the controller differs much from disable_irq.
Locking all the interrupts is definitely worse than disabling selected ones. Also, introducing locks here means that we'll need to handle that specifically for -rt kernels.
 
> 2) If we are calling gfar_transmit and gfar_receive, shouldn't we  
> call gfar_error?
> 
> 3) I think it should be possible to just call gfar_interrupt() in  
> every situation, but I'm not very familiar with net poll's  
> requirements (You can add that into your evaluation of #1, too).

Oh yes, that's a nice idea, thanks.

Vitaly
