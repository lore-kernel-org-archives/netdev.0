From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ISDN testing
Date: Thu, 24 Apr 2008 22:39:07 -0400
Message-ID: <4811444B.1@garzik.org>
References: <20080420223959.GA17998@havoc.gtf.org>	<200804210205.38891.elendil@planet.nl> <480BF15D.2090100@garzik.org>	<200804211536.57655.elendil@planet.nl> <480CE960.4050000@garzik.org> <878wz76lbr.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Frans Pop <elendil@planet.nl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46238 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753285AbYDYCjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 22:39:13 -0400
In-Reply-To: <878wz76lbr.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Jeff Garzik <jeff@garzik.org> writes:
>> Yeah, that's what my patchset does -- splits the "hisax" driver into
>> multiple smaller drivers.  Thus, "modprobe hisax" produces the results
>> that you are seeing.
> 
> That will break a lot of user's setup.

At present, yes :/  Yet another why it's not upstream :)


>> You'll need to determine which newly-created kernel module applies to
>> your hardware.  Let me know if you need help with that.  The new
>> drivers should be in
>> /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/ provided that you
>> enabled them in the kernel configuration.
> 
> One way to avoid that issue would be to continue having a dummy
> "hisax" module that just depends on all the other drivers with 
> a symbol reference.

I'm definitely open to any solution like this.  Unfortunately (as Frans, 
I think, pointed out) the hisax module routinely depends on critical 
setup info being passed as module options, mainly for non-PCI hardware.

One solution might be to create a dummy hisax module that calls 
foo_module_init() and foo_module_exit(), and stitch them together in an 
unconventional way.

	Jeff



