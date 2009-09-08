From: Andreas Jaggi <aj@open.ch>
Subject: Re: H.245v10+ support in nf_conntrack_h323?
Date: Tue, 8 Sep 2009 15:04:24 +0200
Message-ID: <20090908130424.GB7273@urbino.open.ch>
References: <20090901092910.GC11354@urbino.open.ch> <20090901100230.GA18651@sirena.org.uk> <4A9D04A2.60307@trash.net> <20090901121033.GA18731@urbino.open.ch> <4A9D11A3.5070809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Jing Min Zhao <zhaojingmin@users.sourceforge.net>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:11870 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912AbZIHNDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 09:03:41 -0400
Content-Disposition: inline
In-Reply-To: <4A9D11A3.5070809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


By using the tcpdumps made during the video conferencing test, I was
able to reproduce the problem with tcpreplay.

Further investigation (eg. sprinkling a couple printks over
nf_conntrack_h323_main.c) showed that the H.245 packet is dropped
because the __nf_ct_expect_check() fails with -EMFILE.
This because max_expected of the H.245 expect policy is reached.

max_expected is set to 'H323_RTP_CHANNEL_MAX * 4 + 2' in
nf_conntrack_h323_main.c and H323_RTP_CHANNEL_MAX is defined as '4'.

Increasing H323_RTP_CHANNEL_MAX solves the problem that H.245 packets
are dropped!

Now I would like to propose a patch to fix this permanently, but I don't
know what a reasonable value for H323_RTP_CHANNEL_MAX would be (only
that the current value is too low for our video conferencing setup).

How was the current value of H323_RTP_CHANNEL_MAX determined? And what
would be the implications of increasing this value?

Andreas
