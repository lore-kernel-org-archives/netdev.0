From: Michael Buesch <mb@bu3sch.de>
Subject: Re: b44: regression in 2.6.22
Date: Sat, 26 May 2007 19:01:17 +0200
Message-ID: <200705261901.18110.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Uwe Bugla <uwe.bugla@gmx.de>,
	Maximilian Engelhardt <maxi@daemonizer.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:48183
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbXEZRB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 13:01:28 -0400
In-Reply-To: <20070525172431.60affaca@freepuppy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 26 May 2007 02:24:31 Stephen Hemminger wrote:
> Something is broken with the b44 driver in 2.6.22-rc1 or later. Now bisecting.
> The performance (with iperf) for receiving is normally 94Mbits or more.
> But something happened that dropped performance to less than 1Mbit,
> probably corrupted packets.
> 
> There is nothing obvious in the commit log for drivers/net/b44.c, so it
> probably is something more general.
> 
> 
> Looking at the code in b44_rx(), I see a couple unrelated of bugs:
> 1. In the small packet case it recycles the skb before copying data out... 
>    Not good if new data arrives overwriting existing data.
> 
> 2. Macros like RX_PKT_BUF_SZ that depend on local variables are evil!!

Very interesting!
2.6.22 doesn't include ssb, does it?

Adding CCs to make reporters of another bugreport aware of this.

-- 
Greetings Michael.
