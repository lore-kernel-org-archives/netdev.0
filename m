From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: skge vs sk98lin
Date: Mon, 14 May 2007 09:01:30 -0700
Message-ID: <20070514090130.1e3bb3f7@freepuppy>
References: <20070508120034.GB1785@mathom.us>
	<20070508101518.288d202a@freekitty>
	<20070514142024.GF1785@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Stone <mstone@mathom.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.linux-foundation.org ([207.189.120.12]:58238 "EHLO
	smtp.osdl.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757270AbXENQBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 12:01:49 -0400
In-Reply-To: <20070514142024.GF1785@mathom.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 May 2007 10:20:26 -0400
Michael Stone <mstone@mathom.us> wrote:

> On Tue, May 08, 2007 at 10:15:18AM -0700, Stephen Hemminger wrote:
> >On Tue, 08 May 2007 08:00:36 -0400
> >Michael Stone <mstone@mathom.us> wrote:
> >> 2.6.21 seems to have fixed the stability issues I was seeing when using 
> >> the skge driver with the older sk98xx dual port fiber cards. There is 
> >> still one more lingering oddness: if I have *two* dual port cards in a 
> >> system, say eth2-5, I see traffic on eth2, eth3, and eth5, but nothing 
> >> on eth4. This seems to be consistent accross a couple of systems I've 
> >> tested; only the first card's second interface sees packets (e.g., with 
> >> tcpdump). If I reboot with the sk98lin driver on the same kernel I see 
> >> all traffic, as expected.
> >
> >Are the statistics changing? ie. ethtool -S eth4 and ifconfig eth4
> 
> Ok, I ran this for a lot longer and it seems less consistent than it did 
> at first. It now appears that there is no correlation between a NIC not 
> working and its order. In some cases the NICs both come up ok, and see 
> traffic for a while. I left one example running over the weekend, and 
> neither interface on one card was seeing traffic, and the interface 
> counters weren't increasing. In another case, one interface on one NIC 
> worked for a short period of time, then stopped. The interface counters 
> would increase by a few packets every 30 seconds or so. Any kind of 
> ethtool operation (e.g., ethtool -A eth4 autoneg off rx off tx off) 
> would cause the interface to start seeing traffic again, then eventually 
> go back to seeing only a few packets every few seconds.
> 
> Mike Stone

Sounds like a missed interrupt getting the driver stuck. skge uses
NAPI and therefore needs level triggered irq's.  What is the
contents of /proc/interrupts?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
