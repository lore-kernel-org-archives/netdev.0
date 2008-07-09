From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Wed, 09 Jul 2008 09:57:05 -0700
Message-ID: <1215622625.5532.43.camel@dell>
References: <20080621113406.5f89ae8d.billfink@mindspring.com>
 <C27F8246C663564A84BB7AB343977242019B6FEC8E@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20080623180439.GA18829@orion.carnet.hr>
 <20080623213657.GA26447@orion.carnet.hr>
 <48602847.1020203@broadcom.com> <48617C19.3010005@broadcom.com>
 <20080626110132.GA30648@orion.carnet.hr>
 <4863DA40.9050508@broadcom.com>
 <20080709164619.GA26098@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Bill Fink'" <billfink@mindspring.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: "Josip Rodin" <joy@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2961 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755966AbYGIQyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 12:54:33 -0400
In-Reply-To: <20080709164619.GA26098@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-09 at 09:46 -0700, Josip Rodin wrote:
> On Thu, Jun 26, 2008 at 11:04:48AM -0700, Michael Chan wrote:
> > 1. SKB is unchanged and the clone bit is set.
> >
> > 2. skb_shared_info(SKB) has dataref 0x00010002 and these fields are
> > changed:
> >
> >    nr_frags changed from n to 1
> >    gso_size changed from 0x5a8 to 0
> >    gso_type changed from 1 (TCP_V4) to 0
> >    gso_segs changed from m to 1
> >    1 of the frags' length is modified to split the TSO packet into 1
> > segment
> >
> > I think this is consistent with what David said about tso_fragment()
> > splitting the cloned TSO SKB into 2.
> 
> Okay, thanks, can you tell me if the previous patch is a proper fix or just
> a workaround?

That was just a debug patch.  The proper fix needs to go into
tso_fragment() as David outlined earlier.

> 
> Recently we've been seeing rsync errors with some of the sites which used to
> be pretty fast - the connection unexpectedly closes, or it times out.
> Something is still fishy about it...
> 

The tso_fragment() issue will always lead to a crash in the bnx2 driver
(before applying any of the debug patches I provided).  If it doesn't
crash, it's probably something else.


