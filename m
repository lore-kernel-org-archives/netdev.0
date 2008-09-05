From: Matt Sealey <matt@genesi-usa.com>
Subject: Re: [PATCH, RFC] mv643xx_eth: move sram window setting code into
 the driver
Date: Fri, 05 Sep 2008 09:31:59 -0500
Message-ID: <48C142DF.70404@genesi-usa.com>
References: <20080903140048.GC19602@xi.wantstofly.org> <48BFE63F.70700@genesi-usa.com> <20080904152032.GB27272@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:59598 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244AbYIEOcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 10:32:02 -0400
Received: by wa-out-1112.google.com with SMTP id j37so303972waf.23
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 07:32:00 -0700 (PDT)
In-Reply-To: <20080904152032.GB27272@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Lennert Buytenhek wrote:
> On Thu, Sep 04, 2008 at 08:44:31AM -0500, Matt Sealey wrote:
> 
>> script, but in either case, wouldn't a real sram node in the device
>> tree be the proper solution here? Hardcoding addresses for devices
> 
> Probably.
> 
> I guess you don't want to pass that info _directly_ to the mv643xx_eth
> driver, though -- since the on-chip SRAM can be used for many things,
> and you're not necessarily sure that the user wants to use it for
> descriptors.  (Or how much of it they want to use for descriptors.)
> (Or for the descriptors of which of the 8 possible transmit and receive
> queues, considering the 2.6.27 driver supports multiple queues.)
> 
> Well, I'm not sure what the best solution is. :-)

In my view... an sram node (it would be /buildin/sram on Pegasos) which
defines the location of sram. In the mv643xx_eth driver you'd check if
you're on Pegasos and set it up, which is what the extra code amounts
to anyway. It just reduces the need to have this address hardcoded in
the kernel. Or, perhaps an sram "driver" - like the sram driver on the
MPC5200B which BestComm relies on. It's simply an rheap wrapper and a
few extra bobbins to find the base address and suchlike from the device
tree.

I'm surprised there isn't a generic sram framework in the same way there
is now a generic GPIO framework. Using rheap allocators and a generic
API you can mark every sram allocation to the owner module/usage..

>> I don't have a Pegasos running right now to test but I will, as soon
>> as possible, make sure this works first.
> 
> Cool, thanks.  It would be nice if you could give the driver in
> 2.6.27-rc5 a spin, it has seen a _lot_ of changes since 2.6.25 and
> I'd really like to make sure it still works on Pegasos.

I will definitely give it a try, time permitting.

-- 
Matt Sealey <matt@genesi-usa.com>
Genesi, Manager, Developer Relations
