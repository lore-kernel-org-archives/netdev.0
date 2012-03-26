From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Question] Kernel preemption of BH handler
Date: Mon, 26 Mar 2012 15:56:14 +0100
Message-ID: <1332773774.3500.87.camel@deadeye>
References: <4F7034EB.8010707@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31733 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932444Ab2CZO4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 10:56:19 -0400
In-Reply-To: <4F7034EB.8010707@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-26 at 11:20 +0200, Erik Hugne wrote:
> I have a BH handler that processes packets received from a netdevice.
> 
> my_bh_handler() {
>    spin_lock_bh(my_lock);
>    /*do stuff*/
>    spin_unlock_bh(my_lock);
>    /*do more stuff*/
> }

spin_lock_bh() means 'spin lock with contending soft-interrupts' and not
'spin lock from a soft-interrupt'.  You probably need to use it in
process context but not here.

> First packet is received, and my_bh_handler() is currently processing it.
> Now a new packet is received by the NIC and my_bh_handler() is preempted 
> after my_lock have been released.

You don't explain how this handler is invoked, but normally it would be
scheduled to run a second time and would not preempt the first call.

Ben.

> Is it possible that the second invocation of the BH routine is allowed 
> to finish before the first?

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
