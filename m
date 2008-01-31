From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] [1/1] Deprecate tcp_tw_{reuse,recycle}
Date: Thu, 31 Jan 2008 07:55:02 +0100
Message-ID: <200801310755.02110.ak@suse.de>
References: <20080130938.523292915@suse.de> <200801310359.07362.ak@suse.de> <47A16CBB.3000409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:43888 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbYAaGzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 01:55:07 -0500
In-Reply-To: <47A16CBB.3000409@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I believe the problem was that all of my ports were used up with
> TIME_WAIT sockets and so it couldn't create more.  My test
> case was similar to this:

Ah that's simple to solve then :- use more IP addresses and bind 
to them in RR in your user program.

Arguably the Linux TCP code should be able to do this by itself
when enough IP addresses are available, but it's not very hard
to do in user space using bind(2)

BTW it's also an very unusual case -- in most cases there are more
remote IP addresses

> So, is there a better way to max out the connections per second without 
> having to use tcp_tw_recycle?

Well did you profile where the bottle necks were?

Perhaps also just increase the memory allowed for TCP sockets.

-Andi


