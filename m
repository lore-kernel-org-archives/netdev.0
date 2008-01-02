From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2 syntax change in tc police?
Date: Wed, 02 Jan 2008 11:14:47 +0100
Message-ID: <1199268887.16358.37.camel@localhost.localdomain>
References: <1199230752.16358.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: shemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:37947 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbYABKLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 05:11:32 -0500
In-Reply-To: <1199230752.16358.22.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On ons, 2008-01-02 at 00:39 +0100, Andreas Henriksson wrote:
[...]
> Commands like "tc filter add dev ppp0 parent ffff: protocol ip prio 50
> u32 match ip src 0.0.0.0/0 police rate 4mbit burst 10k drop flowid :1"
> apparently no longer works. The flowid is not accepted anymore.
> Reverting commit 720a2e8d99... which you authored seems to "fix" this.
[...]


After further investigation it seems clear to me that reverting the
commit 720a2e8d990707749b2... is the correct thing to do, since the real
fix for the problem this commit was supposed to fix was instead fixed in
commit c29391c7c68f031e246c...

Whatever you specify after a u32 police you will now get a syntax error,
and according to "tc filter add u32 help" there are several things that
you are supposed to be able to specify after a police.

So, Steven, please revert 720a2e8d990707749b2...


-- 
Regards,
Andreas Henriksson

