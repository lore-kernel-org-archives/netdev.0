From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFT] geneve: implement support for IPv6-based tunnels
Date: Tue, 29 Sep 2015 18:10:07 +0200
Message-ID: <20150929181007.55ecc3a2@griffin>
References: <1443119682-14236-1-git-send-email-linville@tuxdriver.com>
	<20150925140844.3e8faae2@griffin>
	<20150928192033.GC19079@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933391AbbI2QKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 12:10:13 -0400
In-Reply-To: <20150928192033.GC19079@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Sep 2015 15:20:33 -0400, John W. Linville wrote:
> > To be really useful, geneve should open both IPv4 and IPv6 socket when
> > it's metadata based. Take a look at my recent patchset that does this
> > for vxlan: http://thread.gmane.org/gmane.linux.network/379282
> 
> OK, that seems simple enough.  So we should just assume that a metadata
> tunnel could do either protocol at any time?  Or are there more rules
> than that?

That should be it, on egress. On ingress, udp_tun_rx_dst needs to be
called with the appropriate family which seems to be missing from your
patch, too (there's AF_INET unconditionally, currently).

 Jiri

-- 
Jiri Benc
