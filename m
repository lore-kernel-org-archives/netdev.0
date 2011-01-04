From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Tue, 04 Jan 2011 15:43:07 +0000
Message-ID: <1294155787.3636.4.camel@bwh-desktop>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
	 <AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
	 <20110103.110244.183045594.davem@davemloft.net>
	 <1294083039.3167.184.camel@localhost> <4D2228E0.9030908@intel.com>
	 <1294085724.3167.202.camel@localhost>
	 <AANLkTimFArsv1gF2BJabvbbQujpHdPC=bO204wkMbR_Z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3623 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab1ADPnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 10:43:10 -0500
In-Reply-To: <AANLkTimFArsv1gF2BJabvbbQujpHdPC=bO204wkMbR_Z@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-03 at 19:25 -0800, Tom Herbert wrote:
> >> The general idea is to at least keep the traffic local to one TX/RX
> >> queue pair so that if we cannot match the queue pair to the application,
> >> perhaps the application can be affinitized to match up with the queue
> >> pair.  Otherwise we end up with traffic getting routed to one TX queue
> >> on one CPU, and the RX being routed to another queue on perhaps a
> >> different CPU and it becomes quite difficult to match up the queues and
> >> the applications.
> >
> > Right.  That certainly seems like a Good Thing, though I believe it can
> > be implemented generically by recording the RX queue number on the
> > socket:
> >
> > http://article.gmane.org/gmane.linux.network/158477
> >
> I still don't see the value in doing this RX/TX queue pairing (unless
> you're considering the possibility of explicitly binding sockets to
> queue pairs).

Sure, the real value is in getting TX completions to line up with TX
initiation and queue pairing is not a reliable way to do that.

> XPS should be sufficient mechanism to get affinity on
> sending side.
[...]

At least if it's configured properly... or if this is automated using my
irq_cpu_rmap.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

