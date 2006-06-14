From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Wed, 14 Jun 2006 16:44:56 -0700
Message-ID: <Pine.CYG.4.58.0606141635440.2888@mawilli1-desk2.amr.corp.intel.com>
References: <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net>
 <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com>
 <x49d5dkvm8p.fsf@segfault.boston.redhat.com> <1149787174.2928.3.camel@strongmad>
 <x49ac8nwo83.fsf@redhat.com> <20060612001356.GA5112@localhost.localdomain>
 <1150130534.2879.9.camel@strongmad> <20060612180600.GB3790@hmsreliant.homelinux.net>
 <20060614204158.GA3967@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:10646 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S965042AbWFNXpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 19:45:51 -0400
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20060614204158.GA3967@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 14 Jun 2006, Neil Horman wrote:

> Hey, as promised, I've done some rudimentary performance benchmarking on various
> ways that we have talked about to solve this problem.  As I previously mentioned

We see the same results here, Neil.  However, we've got a much less
invasive patch undergoing internal review, and which we will post to
netdev once everybody gets happy with it.  Basically, we just do our NAPI
scheduling on the "real" netdev structure instead of our polling netdev,
in the case where we only have one RX queue.  Since this is the case for
all our currently-shipping parts under Linux, netpoll works again across
the board.  It's a short-term fix because we do want to support multiple
queues going forward, but for now we need to get everybody working.

One of our engineers (on the I/O AT team) has been tasked with modifying
the Linux kernel to properly support multiple hardware queues (both TX and
RX).  We'll make sure that he looks at the netpoll interface as part of
that process.

Stay tuned for our impending patch.
-Mitch

