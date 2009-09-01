From: Andreas Jaggi <aj@open.ch>
Subject: Re: H.245v10+ support in nf_conntrack_h323?
Date: Tue, 1 Sep 2009 14:10:33 +0200
Message-ID: <20090901121033.GA18731@urbino.open.ch>
References: <20090901092910.GC11354@urbino.open.ch> <20090901100230.GA18651@sirena.org.uk> <4A9D04A2.60307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Jing Min Zhao <zhaojingmin@users.sourceforge.net>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:65239 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799AbZIAMJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 08:09:52 -0400
Content-Disposition: inline
In-Reply-To: <4A9D04A2.60307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 01:25:22PM +0200, Patrick McHardy wrote:
> Mark Brown wrote:
> > I'd be surprised if the H.245 version were the source of your problems
> > here - the new protocol versions are backwards compatible and I don't
> > remember any changes in any of the stuff that's relevant for firewall
> > transit.
> 
> Good point. The helper should also log packets dropped due to parsing
> errors. If you don't get any messages, I'd suggest to use the iptables
> TRACE target to figure out where the packets are dropped exactly.

I'm quite confident that the H.245 parsing/handling is involved in the
packet dropping:
1. there are plenty of 'nf_ct_h245: packet dropped' messages
   (but no nf_ct_q931 or nf_ct_ras messages)
2. without nf_conntrack_h323 the videoconferencing works seamlessly
3. with nf_conntrack_h323 and a ...-j NOTRACK rule the videoconferencing
   works too

In our setup there is a LOG rule preceding any DROP or ACCEPT rule, and
there were no logentries for DROP rules showing up (only the nf_ct_h245:
packet dropped messages).
Would a TRACE rule provide more insight than this? (eg. by showing in
which part of the nf_conntrack_h323 code a packet is dropped?)

For me it looks like nf_conntrack_h323 is not only doing connection
tracking, but also doing protocol enforcement (by dropping packets which
do not correspond exactly to H.245v7).
Perhaps there should be a config option to disable the protocol
enforcement?

Andreas
