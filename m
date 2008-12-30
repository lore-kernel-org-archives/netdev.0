From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [2.6.28] NULL pointer dereference at get_stats()
Date: Wed, 31 Dec 2008 02:01:56 +0900
Message-ID: <200812310201.GJH43235.OFFLHFMStOJVOQ@I-love.SAKURA.ne.jp>
References: <200812302153.ECH86976.MFLOQFJHtSOOFV@I-love.SAKURA.ne.jp>
	<20081230155215.GA31531@gambetta>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, netdev@vger.kernel.org
To: frederik.deweerdt@xprog.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:61065 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813AbYL3RB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 12:01:57 -0500
In-Reply-To: <20081230155215.GA31531@gambetta>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Frederik Deweerdt wrote:
> Does adding maxcpus=0 to the boot parameters solve the problem? Stephen
> suspected a per-cpu variable related problem.

No, but I got interestring results.

Result | # of virtual CPUs | Kernel command line
-------+-------------------+-----------------------------------------
 OK    | 2                 | ro root=LABEL=/
 BUG   | 2                 | ro root=LABEL=/ noapic nolapic
 BUG   | 2                 | ro root=LABEL=/ noapic nolapic maxcpus=0
 BUG   | 2                 | ro root=LABEL=/ noapic nolapic nosmp
 BUG   | 2                 | ro root=LABEL=/ maxcpus=0
 BUG   | 2                 | ro root=LABEL=/ nosmp
 OK    | 1                 | ro root=LABEL=/
 OK    | 1                 | ro root=LABEL=/ nolapic noapic
 OK    | 1                 | ro root=LABEL=/ nolapic noapic maxcpus=0
 OK    | 1                 | ro root=LABEL=/ nolapic noapic nosmp

"OK" means NULL pointer dereference didn't happen.
"BUG" means NULL pointer dereference happened.

I was adding "noapic" "nolapic" to command line while assigning 2 vcpus.
Thus, I encountered this problem. Workaround is to remove "noapic" "nolapic".

Now, it seems to me that this problem is caused by interaction of
"noapic" "nolapic" "maxcpus=0" "nosmp" options.

Regards.
