From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 2/2] e1000: remove risky prefetch on next_skb->data
Date: Mon, 5 Jun 2006 17:12:31 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0606051707520.1168@jbrandeb-desk.amr.corp.intel.com>
References: <20060605230917.12584.55755.stgit@gitlost.site>
 <20060605231127.12584.14321.stgit@gitlost.site> <4484BC62.3090707@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:12257 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751174AbWFFANP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 20:13:15 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4484BC62.3090707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Jun 2006, Rick Jones wrote:

> 
> Kok, Auke wrote:
> > It was brought to our attention that the prefetches break e1000 traffic
> > on xscale/arm architectures.  Remove them for now.  We'll let them
> > stay in mm for a while, or find a better solution to enable.
> 
> Out of curiousity, what breaks?

Hi Rick, according to our reporter, receives break.  The prefetch (not 
always, but sometimes) lets the processor get junk from the prefetched 
area.  Apparently this version of arm doesn't quite do as strict 
enforcement of bus snoops as x86, ia64, (and even pSeries!) does.

This manifested with a large drop in receive peformance using TCP, 
probably because it was retransmitting frequently.

Jesse
