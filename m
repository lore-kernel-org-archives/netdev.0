From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [RFC][PATCH] static builtin CCIDs was  Re: [PATCH 2/5] dccp:
	Auto-load (when supported) CCID plugins for negotiation
Date: Thu, 18 Dec 2008 08:55:02 -0200
Message-ID: <20081218105502.GA21653@ghostprotocols.net>
References: <20081216111908.GI14518@ghostprotocols.net> <20081216.133200.229085084.davem@davemloft.net> <20081216222559.GR14518@ghostprotocols.net> <20081216.151151.220977047.davem@davemloft.net> <20081217131347.GS14518@ghostprotocols.net> <20081217182038.GV14518@ghostprotocols.net> <20081217183041.GW14518@ghostprotocols.net> <20081218054110.GA6298@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>, mirqus@gmail.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:11773 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbYLRKzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 05:55:14 -0500
Received: by yx-out-2324.google.com with SMTP id 8so136375yxm.1
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2008 02:55:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081218054110.GA6298@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Dec 18, 2008 at 06:41:10AM +0100, Gerrit Renker escreveu:
> Quoting Arnaldo:
> | Em Wed, Dec 17, 2008 at 04:20:38PM -0200, Arnaldo Carvalho de Melo escreveu:
> | > > IOW we're back to my suggestion on looking at
> | > > tcp_set_congestion_control(). :-)
> | > 
> | > I tried to test this using ttcp over loopback but the tree seems broken
> | > somehow, with or without this patch I'm getting:
> | > 
> | > Could not activate 0 at /home/acme/git/net-next-2.6/net/dccp/feat.c:1176
> | > 
> | > I tried doing a quick chase on this one but failed miserably, Gerrit,
> | > any ideas?
> | 
> | Well, without the patch the problem was that dccp_ccid2 was not being
> | autoloaded, as soon as I manually loaded it, ttcp worked. Now to see
> | why...
> I have acked your patch but haven't had time to compile and test it.
> Will do this in due course and integrate it into the test tree. 
> 
> With regard to the error message, this says that the feature with index 0
> could not be activated. According to table 6.4 in RFC 4340 this is a bug

I figured that out later, after some more tweaking and systemtapping it
ended up with index 5 failing and that was the ackvec code that was not
being included, just the stubs that always return NULL on the allocation
routine, after that was fixed by removing CONFIG_IP_DCCP_ACKVEC, i.e.
always including that code since CCID2 now is always included, all
worked with a simple, over loopback, ttcp test.

> because it tries to activate a reserved feature.
 
> Will do in-depth testing later on today.

Thanks!

- Arnaldo
