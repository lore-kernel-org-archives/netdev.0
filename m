From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: dropwatch for network drop monitor
Date: Fri, 17 Apr 2009 20:13:58 +0200
Message-ID: <49E8C6E6.9020601@hartkopp.net>
References: <200904171257.n3HCvOba029938@post.webmailer.de> <20090417132848.GA2723@hmsreliant.think-freely.org> <49E88F2A.4010301@hartkopp.net> <20090417172239.GC2723@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:40870 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761015AbZDQSOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 14:14:03 -0400
In-Reply-To: <20090417172239.GC2723@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:

> 
> Quick update for you, I've reproduced the problem.  The inability to restart
> after the first few errors is actually by design.  Since you had to kill the
> user space process, it left the kernel bits in a state where they were still
> monitoring, so a second start command (when you restarted the user space daemon)
> caused an error, and the program shutdown (which I probably shouldn't do,
> returning instead to the command console).  You can work around this by issuing
> a stop command, which successfully stops the kernel bits and lets you restart
> them.

Hard terminations are mostly critical to handle. I'll try the workaround.

> 
> This also tells me that the kernel netlink warning is not fatal (as our netlink
> message commands are getting processed properly).  I still need to figure out
> why thats happening though.
> 

Ok.

> As for the ctrl-c issue, I've got no idea whats going on there, its like the
> recv operation is restarting after we catch the SIGINT.  I think I may just
> switch that to a poll operation on the netlink socket and stdin input.  That
> should fix that up quick.  Expect a git commit on that sometime this weekend,
> and some subseqent netdev posts to fix the kernel bits. 

You can also send me an off-list mail when you have something to test this
weekend.

I can produce a lot of drops on my machine ;-)

Regards,
Oliver

