From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Thu, 26 Jul 2007 00:05:47 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AAB9F8@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070725.233808.41635535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2997 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754596AbXGZHGB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 03:06:01 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070725.233808.41635535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> So that ->poll_controller() can process TX acks by just having
> the TX lock and interrupts disabled.
> 
> Can you think of another way to process TX acks from absolutely
> any execution context whatsoever?  That's what we need and
> preferably in some generic way, and the above is what I came
> up with.

What are we trying to protect against by taking the TX lock before
calling ->poll_controller()?

> 
> To be honest I don't think the TX lock contention will matter, and
> even if there were a small cost, the simplicity of the netpoll
> implementation is worth it given how problematic and hard to debug
> netpoll has been in the past.
> 
>

There is a measurable difference in oprofile.  When passing small
packets, there's a non-trivial difference in throughput.

