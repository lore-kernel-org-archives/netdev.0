From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 4/9] rdma/cm: Update port reservation to support AF_IB
Date: Wed, 13 Feb 2013 11:10:48 -0700
Message-ID: <20130213181048.GC1601@obsidianresearch.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
 <1358891797-14625-5-git-send-email-sean.hefty@intel.com>
 <511B7474.3040201@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A8237368B9A40F@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Hefty, Sean" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53693 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965351Ab3BMSKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 13:10:44 -0500
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A8237368B9A40F@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2013 at 05:44:58PM +0000, Hefty, Sean wrote:

> Ultimately, IB establishes communication using 64-bit service IDs, which is what sockaddr_ib exposes.
> 
> The SID mask was proposed by Jason as a way to simplify things.
> Conceptually, AF_IB has a single port space range, the 64-bit SID.
> The mask helps us break the SID into the various ranges, so we can
> clearly know which parts of the SID are fixed, and which can be
> variable.  E.g. when connecting, the entire SID must be provided.
> However, when binding we want to support binding to a specific SID
> or only to a SID range (i.e. port space).

Right. AF_IB is about exposing the native IB CM, rather than a cooked
version of it, so allowing user space to control the entire SID is
desirable.

The intent of the masking was to provide a means for the kernel to
atomically select a process-unique ID (such as the 16 bits the IP
varient requires) for listening.

Other uses of IB CM would use a different prefix, but will still
fundamentally require a machine unique portion.

This addresses a fundamental problem in ib_ucm - there is no way for
multiple processes to co-ordinate on unique SIDs.

Sean, I've lost track of all this over time, but just to check in,
with this new interface, would it be possible to obsolete ib_ucm? That
seems desirable to me, as it is so flawed..

Jason
