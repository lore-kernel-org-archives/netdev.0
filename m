From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 3/3] tc: pedit: Fix retain value for ihl
 adjustments
Date: Thu, 3 Mar 2016 15:54:31 +0100
Message-ID: <20160303145431.GD18624@orbyte.nwl.cc>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
 <499abfe479324d1e83289cd68b2a7641@HQ1WP-EXMB11.corp.brocade.com>
 <20160302095414.45a928df@xeon-e3>
 <56D84863.5090203@mojatatu.com>
 <56D84A0B.6000003@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41466 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757916AbcCCOyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 09:54:33 -0500
Content-Disposition: inline
In-Reply-To: <56D84A0B.6000003@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 09:28:27AM -0500, Jamal Hadi Salim wrote:
> Phil, there is one thing i noticed in your patch - dont think
> it is a big deal but you are doing htons on an int
> (instead of u16).

Indeed, I totally overlooked that. Does not look like there's an easy
fix though, as all tc_pedit_key fields are u32. OTOH htons() will cast
to u16 first, therefore cutting off any higher bits. Looks like the code
does the right thing anyway, and the test results fortify that.

Do you see a cleaner way to implement this? Otherwise I would vote for
leaving it as a little surprise to future readers. ;)

Cheers, Phil
