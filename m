From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: iproute2 syntax change in tc police?
Date: Wed, 2 Jan 2008 02:43:44 +0200
Message-ID: <20080102003909.M73325@visp.net.lb>
References: <1199230752.16358.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev <netdev@vger.kernel.org>
To: Andreas Henriksson <andreas@fatal.se>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:43887 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbYABMKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 07:10:21 -0500
In-Reply-To: <1199230752.16358.22.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe something like 
-tc filter add dev ppp0 parent ffff: protocol ip prio 50 u32 match ip src 
0.0.0.0/0 police rate 4mbit burst 10k drop flowid :1
+tc filter add dev ppp0 parent ffff: protocol ip prio 50 u32 match ip src 
0.0.0.0/0 flowid :1 police rate 4mbit burst 10k drop 

I can't test it now, but in my case moving flowid BEFORE police (or somewhere 
else "before", i dont remeber well) - helped.

On Wed, 02 Jan 2008 00:39:11 +0100, Andreas Henriksson wrote
> Hello Patrick McHardy!
> 
> We have recently updated iproute in debian and have reports about the
> new version breaking shorewall generated scripts.
> 
> The original bug-report can be found at:
> http://bugs.debian.org/458539
> 
> Commands like "tc filter add dev ppp0 parent ffff: protocol ip prio 
> 50 u32 match ip src 0.0.0.0/0 police rate 4mbit burst 10k drop 
> flowid :1" apparently no longer works. The flowid is not accepted anymore.
> Reverting commit 720a2e8d99... which you authored seems to "fix" this.
> 
> http://git.kernel.org/?p=linux/kernel/git/shemminger/
iproute2.git;a=commitdiff;h=720a2e8d990707749b2cafa77ab3cd2b8241ec47
> 
> I guess the flowid is invalid syntax, but that it just got ignored
> instead of caught before... 
> Could you please have a look and tell me what you think about this?
> 
> -- 
> Regards,
> Andreas Henriksson
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

