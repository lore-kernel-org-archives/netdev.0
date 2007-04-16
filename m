From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8325] New: -j REDIRECT --to-ports 1000-1009,
 always first choosen
Date: Mon, 16 Apr 2007 07:52:06 +0200
Message-ID: <46230F06.4020201@trash.net>
References: <200704132053.l3DKrC9X000466@fire-2.osdl.org> <20070413144702.8ebf1cfe.akpm@linux-foundation.org> <462305C1.9030007@trash.net> <20070416052535.M41456@visp.net.lb> <462309F9.6050005@trash.net> <20070416054247.M18950@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: wijata@nec-labs.com, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64720 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbXDPFyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 01:54:09 -0400
In-Reply-To: <20070416054247.M18950@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> On Mon, 16 Apr 2007 07:30:33 +0200, Patrick McHardy wrote
> 
>>That makes sense with using multiple IPs (and we support doing that),
>>but whats the point of load-balancing to differenet *ports*?
> 
> 
> Easy - for example i have my own TCP acceleration solution, which is using 
> REDIRECT, then getsockopt/SO_ORIGINAL_DST to get original IP, then forwarding 
> to compressed tunnel, stripping unneeded bytes (oh, my expensive satellite 
> bandwidth). This way for example i can do some kind load-balancing for 
> satellite bandwidth. 


That sounds rather hackish, you might as well do it in your application.

I just noticed we don't accept the random option for DNAT/REDIRECT yet,
but that is easily fixed (I'll queue a patch for 2.6.22). Then this
will work and select ports from the range randomly:

iptables -t nat -A INPUT .. -j REDIRECT --to-ports 1000:1010 --random
