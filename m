From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted
 to managed
Date: Thu, 4 Oct 2007 08:54:40 -0700
Message-ID: <20071004085440.008216c6@freepuppy.rosehill>
References: <20071004113343.552139D502B@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, johannes@sipsolutions.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38260 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757351AbXJDP4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 11:56:39 -0400
In-Reply-To: <20071004113343.552139D502B@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  4 Oct 2007 12:33:43 +0100 (BST)
Daniel Drake <dsd@gentoo.org> wrote:

> This sequence of events causes loss of connectivity:
> 
> <plug in>
> <associate as normal in managed mode>
> ifconfig eth7 down
> iwconfig eth7 mode monitor
> ifconfig eth7 up
> ifconfig eth7 down
> iwconfig eth7 mode managed
> <associate as normal>
> 
> At this point you are associated but TX does not work. This is because
> the eth7 hard_start_xmit is still ieee80211_monitor_start_xmit.
> 
> Fix this by unsetting the hard_start_xmit handler in ieee80211_if_reinit. It
> will then be reinitialised to the default (ieee80211_subif_start_xmit) in
> ieee80211_if_set_type.
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>

Playing with the function pointer is a awkward way to do this.  Shouldn't
the state management flags be used instead (dormant, running, stop/wake)...
I am concerned about races and dereferencing the NULL ptr.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
