From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 14:39:56 +0000
Message-ID: <562F8CBC.7080800@oracle.com>
References: <562F7E16.2070906@oracle.com>	<20151027.065924.796277086557445997.davem@davemloft.net>	<562F868B.4040001@oracle.com> <20151027.073914.310976982324296607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19679 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932306AbbJ0OkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:40:04 -0400
In-Reply-To: <20151027.073914.310976982324296607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/10/2015 14:39, David Miller wrote:

> You will never be able to assume it is available everywhere under
> Linux.  Ever.
>
> This is the fundamental issue that you seem to completely not
> understand.

If that was true in general then Linux would be dead and there would be 
no point ever adding any new features to it.

> You cannot just assume 5 years from now or whatever that the close()
> thing is there even if I added it to the tree right now.

No, a configure-time feature probe would be needed, as is generally 
considered to be good practice.

> Your intent is to somewhere down the road assume this, and therefore
> distribute a broken piece of infrastructure that only works on some
> Linux systems.
>
> This is not acceptable.

Acceptable to who? Unless you are claiming to speak for the authors of 
every piece of software that ever runs on Linux you can't make that 
assertion. For example, Hadoop relies on Linux CGroups to provide 
features you'd want in production deployments, yet CGroups only appeared 
in Linux 2.6.24.

> The backwards compat code will need to be in your code forever.  There
> is no way around it.  That is, again, unless you want your code to not
> work on a non-trivial number of Linux systems out there.

That's simply not true. Both Linux and Solaris have dropped support for 
old features in the past. Yes it takes a long time to do so but it's 
perfectly possible.

> Making this worse is that there isn't going to be a straightforward
> nor reliable way to test for the presence of this at run time.

I attached a test case to the original bug that demonstrates the 
platform-specific behaviours, it would be easy enough to modify that to 
use as a configure-time feature probe.

> You _have_ a way to accomplish what you want to do today and it works
> on every Linux system on the planet.
>
> Given the constraints, and the fact that you're going to have to
> account for this situation somehow in your code forever, I see very
> little to no value in adding the close() thing.

I think your assessment is unduly pessimistic.

> So your cross-platform unified behavior goal is simply unobtainable.
> So please deal with reality rather than wishful inpractical things.

If you don't think this is worth discussing because you personally don't 
believe cross-platform compatibility is worth bothering with then fine, 
say so. But then you need to persuade everyone else with a stake in 
Linux that your viewpoint is the only valid one, and you will have to 
also persuade them that Linux should no longer concern itself with POSIX 
compliance. I know *I* couldn't do that for Solaris, and with all due 
respect, I very much doubt *you* can do so for Linux.

-- 
Alan Burlison
--
