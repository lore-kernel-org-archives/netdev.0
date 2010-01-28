From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: CBQ broken in 2.6
Date: Thu, 28 Jan 2010 12:53:17 +0000
Message-ID: <20100128125317.GA8931@ff.dom.local>
References: <1264595308.29501.30.camel@tranquility.sigsegv.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:60162 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab0A1Mx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 07:53:26 -0500
Received: by fxm20 with SMTP id 20so618329fxm.21
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 04:53:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1264595308.29501.30.camel@tranquility.sigsegv.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27-01-2010 13:28, Anton Ivanov wrote:
> Thanks it is indeed sch_cbq.c,
> 
> I have been going through the code in the meantime and found a place
> where cl->tparent can be modified further down in the routine in
> question. There is an invocation of cbq_set_lss() around the end of
> cbq_change_class() which can do that.
> 
> I am rebuilding the kernel for my CBQ box with a few printks at the
> moment to see if it modified there or not.
> 
> In any case here is the tell-tale symptom:
> 
> class cbq 1:16 parent 1: leaf 76: rate 5600Kbit (bounded,isolated) prio
> 2
>  Sent 162051 bytes 925 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>   borrowed 201 overactions 0 avgidle 78 undertime 0
> 
> That is a bounded class. Its borrowed should be always 0 no matter what.
> That is basically a broken CBQ implementation.
> 
> An elementary network test suite shows the same result - it is being
> allowed to borrow.
> 
> I am happy to send the whole config if necessary if someone wants to
> look at it.

Was this class created as bounded or changed later? Did it have any
child?

Jarek P.
