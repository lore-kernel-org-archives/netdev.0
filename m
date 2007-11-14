From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Tue, 13 Nov 2007 18:12:18 -0800
Message-ID: <20071114021131.GB2523@verge.net.au>
References: <200711131129.58868.borntraeger@de.ibm.com> <20071113.024500.155458534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: borntraeger@de.ibm.com, netdev@vger.kernel.org,
	ebiederm@xmission.com, wensong@linux-vs.org, ja@ssi.bg
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36555 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772AbXKNPWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 10:22:06 -0500
Content-Disposition: inline
In-Reply-To: <20071113.024500.155458534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 02:45:00AM -0800, David Miller wrote:
> From: Christian Borntraeger <borntraeger@de.ibm.com>
> Date: Tue, 13 Nov 2007 11:29:58 +0100
> 
> > Running the latest git code I get the following messages during boot:
> > sysctl table check failed: /net/ipv4/vs/drop_entry .3.5.21.4 Missing strategy
> > [...]		  
> > sysctl table check failed: /net/ipv4/vs/drop_packet .3.5.21.5 Missing strategy
> > [...]
> > sysctl table check failed: /net/ipv4/vs/secure_tcp .3.5.21.6 Missing strategy
> > [...]
> > sysctl table check failed: /net/ipv4/vs/sync_threshold .3.5.21.24 Missing strategy
> > 
> > I removed the binary sysctl handler for those messages and also removed
> > the definitions in ip_vs.h. The alternative would be to implement a 
> > proper strategy handler, but syscall sysctl is deprecated.
> > 
> > There are other sysctl definitions that are commented out or work with 
> > the default sysctl_data strategy. I did not touch these. 
> > 
> > Eric, IPVS team, are you ok with that change?
> > 
> > CC: Eric W. Biederman <ebiederm@xmission.com>
> > CC: Wensong Zhang <wensong@linux-vs.org>
> > CC: Simon Horman <horms@verge.net.au>
> > CC: Julian Anastasov <ja@ssi.bg>
> > Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> 
> Simon planned to make a similar change to dice all of this
> stuff up.  He is travelling currently, and I think it's
> reasonable to give him some time to get to it.

Hi Christian, Hi Dave,

I have indeed been looking into this of late. Assuming that you use of
CTL_UNNUMBERED is correct, this patch looks fine to me.  Acked.

I was planning to do the same and also switch over all the other entries
over to use CTL_UNNUMBERED, as its hard to imagine that anyone is using
the sys_sysctl interface to IPVS.

As for the commented out entries. They are supposed to be exposed by
some other means - I believe the thinking was to comply with the don't
expose stuff in proc any more idea. Where is the best place to expose
this kind of stuff?

Lastly, as Dave mentions, I'm travelling this week, so please
excuse any slowness.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

