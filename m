From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iproute2: Fix building xt module against xtables version
 6
Date: Mon, 4 Jul 2011 18:11:35 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1107041752390.8555@frira.zrqbmnf.qr>
References: <20110704151742.GA6819@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:51887 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758141Ab1GDQLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 12:11:37 -0400
In-Reply-To: <20110704151742.GA6819@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 2011-07-04 17:17, Andreas Henriksson wrote:

>iptables/xtables apparently changed API again.... Now you need to pass
>and extra parameter (orig_opts) which was not needed before.
>
>Sprinkle some lovely pre-processor magic to be compatible with both older
>and new versions. In the beginning of times XTABLES_VERSION_CODE didn't
>exist. Then it was (0x10000 * major + 0x100 * minor + patch) when it was
>first introduced (according to git), but now it's at 6...
>Don't know what official iptables releases has defined it to over time.

It reflects the soversion, IOW, the ABI (if the developer feels like it, 
also API). This increases only when needed rather than at every release. 
It also won't reach versions >=0x10000 anytime soon because of that. 
More importantly though, the API drafting was just finalized for 1.4.3 
(XTABLES_VERSION_CODE=1), so anything before that is a very blurry 
construct anyway.


>Lets just hope none of the older versions with is has the define
>higher then 6 is still around.... so only the "current" versioning
>scheme is supported.... lets see how long this lasts now.
