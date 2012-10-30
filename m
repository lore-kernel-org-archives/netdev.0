From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Tue, 30 Oct 2012 14:51:56 +0000
Message-ID: <20121030145156.GN13450@casper.infradead.org>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org>
 <20121026143704.GC25087@hmsreliant.think-freely.org>
 <20121029084143.GA17442@casper.infradead.org>
 <20121029113700.GA9332@hmsreliant.think-freely.org>
 <508EE586.9060907@gmail.com>
 <20121030125230.GB13450@casper.infradead.org>
 <508FE34D.8010402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56903 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab2J3OwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 10:52:01 -0400
Content-Disposition: inline
In-Reply-To: <508FE34D.8010402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/12 at 10:25am, Vlad Yasevich wrote:
> Can you give me some reasons why you prefer 0?
> 
> 0 seems a bit strange to me.  if someone was to construct a
> histogram of values, they would start with some initial value, then
> see 0s if there is no change, a spike for large rto, and if the
> spike is corrected, it would drop to 0 indicating no change...
> Seems odd.
> 
> I would rather see what the current observed max rto is for an
> application polling period.  Then a histogram can be correctly
> constructed.

0 would indicate that the rto has not been recalculated since
the last read and the app can decideitself whether to ignore
that read, replace it with rto_min or use the last known good
rto_max value.

Obviously this would mean that the patch needs to be changed
so it updates the max observed rto after applying rto_min in
sctp_transport_update_rto().

I'm perfectly fine with using rto_min as well though, we just lose
a bit of information that may be helpful to some users.
