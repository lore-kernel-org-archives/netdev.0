From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 26 Oct 2006 03:49:41 +0200
Message-ID: <45401435.3080407@trash.net>
References: <C86180A8C204554D8A3323D8F6B0A29F018B54D4@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:7412 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965271AbWJZBuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 21:50:08 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B54D4@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Barber wrote:
> Pfifo_fast does not make sense because the 802.11 qdisc already
> categorizes the frames based on DSCP. The better thing would be to
> extract the pfifo qdisc so that it does not require NET_SCHED, but this
> is more work.

It wouldn't really hurt though since all frames queued to a band already
have the same priority, so pfifo_fast behaves similar to fifo.

BTW, is there a specific reason for using DSCP? Normally Linux uses
rt_tos2priority and prio2band for determining a priority for IP packets.
I don't want to argue that one is better than the other, but there
is some value in keeping things consistent ..

