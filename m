From: Hans Henrik Happe <hhh@imada.sdu.dk>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Sat, 29 Jul 2006 18:36:17 +0200
Message-ID: <200607291836.18514.hhh@imada.sdu.dk>
References: <20060709132446.GB29435@2ka.mipt.ru> <20060729154401.GA25926@2ka.mipt.ru> <44CB8A67.3060801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from berlioz.imada.sdu.dk ([130.225.128.12]:53157 "EHLO
	berlioz.imada.sdu.dk") by vger.kernel.org with ESMTP
	id S1751372AbWG2QgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 12:36:21 -0400
Received: from localhost (localhost [127.0.0.1])
	by localhost.imada.sdu.dk (Postfix) with ESMTP id 5243D62718
	for <netdev@vger.kernel.org>; Sat, 29 Jul 2006 18:36:20 +0200 (CEST)
Received: from berlioz.imada.sdu.dk ([127.0.0.1])
 by localhost (berlioz.imada.sdu.dk [127.0.0.1]) (amavisd-new, port 10025)
 with ESMTP id 29770-07 for <netdev@vger.kernel.org>;
 Sat, 29 Jul 2006 16:36:20 +0000 (UTC)
Received: from [192.168.2.101] (unknown [85.218.152.97])
	(using SSLv3 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by berlioz.imada.sdu.dk (Postfix) with ESMTP id 0140962711
	for <netdev@vger.kernel.org>; Sat, 29 Jul 2006 18:36:20 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <44CB8A67.3060801@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 29 July 2006 18:18, Ulrich Drepper wrote:
> Evgeniy Polyakov wrote:
> > Btw, why do we want mapped ring of ready events?
> > If user requestd some event, he definitely wants to get them back when
> > they are ready, and not to check and then get them?
> > Could you please explain more on this issue?
> 
> If of course makes no sense to enter the kernel to actually get the
> event.  This should be done by storing the event in the ring buffer.
> I.e., there are two ways to get an event:
> 
> - with a syscall.  This can report as many events at once as the caller
>   provides space for.  And no event which is reported in the run buffer
>   should be reported this way
> 
> - if there is space, report it in the ring buffer.  Yes, the buffer
>   can be optional, then all events are reported by the system call.
> 
> 
> So the use case would be like this:
> 
> 
> wait_and_get_event:
> 
>   is buffer empty ?
> 
>     yes -> make syscall
> 
>     no -> get event from buffer
> 
> 
> To avoid races, the syscall needs to take a parameter indicating the
> last event checked out from the buffer.  If in the meantime the kernel
> put another event in the buffer the syscall immediately returns.
> Similar to what we do in the futex syscall.

Couldn't this be done in a general way: Given a fd that supports streaming 
input, map some user-mem as a ring buffer for input. Maybe the kernel should 
control the buffer in order to make resizing possible (i.e., TCP zero-copy 
and window scaling).

Hans Henrik 
