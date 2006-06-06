From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hush noisy ieee80211 CCMP printks
Date: Mon, 5 Jun 2006 20:41:38 -0700
Message-ID: <20060606034138.GB9568@jm.kir.nu>
References: <20060605001208.GA4585@opus.vpn-dev.reflex> <20060605133147.GA9567@jm.kir.nu> <20060605160335.GB25688@knob.reflex>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:5289 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP
	id S1750837AbWFFDmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 23:42:17 -0400
To: Jason Lunz <lunz@falooley.org>
Content-Disposition: inline
In-Reply-To: <20060605160335.GB25688@knob.reflex>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 12:03:35PM -0400, Jason Lunz wrote:
> If these are a real problem, I'll gladly help debug it. I'm using
> 2.6.17-rc5's bcm43xx and the in-kernel ieee80211 softmac stack. I'm
> using wpa/ccmp/aes with an openwrt AP.

Do you happen to have a wireless sniffer that you could use to capture
the frames? It would be interesting to see whether such a capture log
could be mapped into the dropped frames shown in the kernel debug log.

> > In many cases, this may be caused by something missing in local
> > filtering (e.g., retry duplicates are not filtered out correctly or
> > messages to incorrect addresses are allowed through, etc.).
> 
> Is it the driver's responsibility to do this filtering, or the softmac
> stack's? Can you show me a code example where this filtering is done
> properly?

This is generic functionality and something I would like to see
implemented in the 802.11 stack so that every low-level driver would not
need to do this. I don't remember what net/ieee80211 code does in this
area. Devicescape code (net/d80211 in wireless-dev.git) has duplicate
detection in ieee80211_rx_h_check().

> I can try different implementations of WPA in the AP if necessary. I
> think openwrt has other options. My end is in-kernel ieee80211_softmac -
> is there anything you'd like me to look at there?

Would you be interested in testing this with net/d80211 code and
wireless-dev.git? It would be interesting to see whether you would get a
different result with the AP end kept in identical configuration and
just changing the client side 802.11 network stack. With net/d80211, the
CCMP replay detection printk is disabled by default (which is what
should be done with net/ieee80211 implementation, too), so that needs to
be enabled at build time. Counters are available from procfs files,
though, so number of replays can be compared.

> If the messages are actually useful, and unusual, then they should
> probably stay. But I get a LOT of them, and my wireless is working just
> fine.

Unfortunately, they are not really unusual. They are useful--at least
for developers--so #ifdef or run-time option for enabling/disabling them
would be nice.

> I noticed that there are counters being incremented where those printks
> are. How do I see those counters from userspace?

These used to be visible from procfs in the original implementation in
Host AP driver. However, it looks like print_stats function is not
called at all in the version that is in net/ieee80211, so the counters
may not be exposed at the moment. They should be, though..

-- 
Jouni Malinen                                            PGP id EFC895FA
