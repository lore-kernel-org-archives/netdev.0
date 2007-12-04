From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Tue, 4 Dec 2007 10:37:52 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712041031110.18529@kivilampi-30.cs.helsinki.fi>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
 <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>  <20071128154725.29af2852@freepuppy.rosehill>
  <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
 <474E0B33.2060108@linux-foundation.org>  <001b01c83248$604f4120$20edc360$@edu>
  <20071203145207.40e4ac57@freepuppy.rosehill>
 <aa7d2c6d0712031506i73df4410p9ab8b1a60bc2ad2d@mail.gmail.com>
 <002f01c83608$8a2fb600$9e8f2200$@edu>  <20071203163217.27e4df3f@freepuppy.rosehill>
 <aa7d2c6d0712031723t314da471n8f033e8d1b523e1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	shaoliu@princeton.edu, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Douglas Leith <doug.leith@nuim.ie>,
	Robert Shorten <robert.shorten@nuim.ie>,
	Netdev <netdev@vger.kernel.org>
To: Lachlan Andrew <lachlan.andrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42327 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbXLDIhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 03:37:54 -0500
In-Reply-To: <aa7d2c6d0712031723t314da471n8f033e8d1b523e1a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Dec 2007, Lachlan Andrew wrote:

> On 03/12/2007, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > On Mon, 3 Dec 2007 15:59:23 -0800
> > "Shao Liu" <shaoliu@Princeton.EDU> wrote:
> > > And also a question, why the samples when SACK is active are outliers?
> >
> > Any sample with SACK is going to mean a loss or reordering has occurred.
> > So shouldn't the SACK values be useful, but RTT values from retransmits
> > are not useful.
> 
> When SACK is active, the per-packet processing becomes more involved,
> tracking the list of lost/SACKed packets.  This causes a CPU spike
> just after a loss, which increases the RTTs, at least in my
> experience.

I suspect that as long as old code was able to use hint, it wasn't doing 
that bad. But it was seriously lacking ability to take advantage of sack 
processing hint when e.g., a new hole appeared, or cumulative ACK arrived.

...Code available in net-2.6.25 might cure those.


-- 
 i.
