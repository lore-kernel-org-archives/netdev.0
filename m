From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2/2] e1000: remove risky prefetch on next_skb->data
Date: Tue, 6 Jun 2006 02:22:18 +0200
Message-ID: <200606060222.18872.ak@suse.de>
References: <20060605230917.12584.55755.stgit@gitlost.site> <Pine.WNT.4.63.0606051707520.1168@jbrandeb-desk.amr.corp.intel.com> <4484C95B.6010009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:11959 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751175AbWFFAWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 20:22:25 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4484C95B.6010009@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Bear with me, I'm a software guy :)  I interpret that to mean that the 
> processor is basically broken?  If so, wouldn't it be the case that 
> prefetch() needs to become a noop on that processor?

I would agree with Rick - if prefetch() is broken on Xscale it should be disabled
in the architecture, not in individual drivers. Otherwise all other code
that use it might be broken too.

Maybe it's only broken on MMIO and not normal memory - in that
case introducing a mmio_prefetch() (and defining it as an nop on Xscale) would be also
an option.

-Andi
