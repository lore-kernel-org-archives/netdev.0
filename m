From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next crap] net: icmp: work around bogus pmtu errors
Date: Tue, 14 Jul 2015 15:40:09 -0700 (PDT)
Message-ID: <20150714.154009.1071789496366560900.davem@davemloft.net>
References: <1436572609-2097-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbbGNWkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 18:40:10 -0400
In-Reply-To: <1436572609-2097-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 11 Jul 2015 01:56:49 +0200

> sometimes tcp connections seem to hang.
> tcpdump shows broken path mtu reports.  This "fix" avoids hang and gives:
> 
> [633.327834] icmp: 192.0.0.2 reports mtu 1474 for packet size 1474 to host 204.236.132.12
> [635.586945] icmp: 192.0.0.2 reports mtu 1474 for packet size 1474 to host 54.219.255.254
> [647.106708] icmp: 192.0.0.2 reports mtu 1474 for packet size 1466 to host 204.236.132.12
> [663.084586] icmp: 192.0.0.2 reports mtu 1474 for packet size 1466 to host 54.219.255.254
> 
> sigh.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Might be caused by DS-LITE.  I either need the turd below or iptables TCPMSS
>  mangling rules to artificially lower received mss.
> 
>  I don't mind if this is rejected; I'm mostly wondering if anyone
>  else came across suprise like this.

I think the culprit should be identified and fixed ASAP, the last thing we want
is for every system add a hack like this.
