From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH RFC] xen-netback: calculate the number of
 slots required for large MTU vifs
Date: Thu, 11 Jul 2013 09:46:27 +0100
Message-ID: <20130711084627.GA23269@zion.uk.xensource.com>
References: <20130709221406.GA13671@u109add4315675089e695.ant.amazon.com>
 <1373409659-22383-1-git-send-email-msw@amazon.com>
 <20130710081333.GI19798@zion.uk.xensource.com>
 <20130710193703.GB20453@zion.uk.xensource.com>
 <20130711051441.GA5189@u109add4315675089e695.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, Annie Li <annie.li@oracle.com>,
	<xen-devel@lists.xenproject.org>, Xi Xiong <xixiong@amazon.com>
To: Matt Wilson <msw@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59297 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755824Ab3GKIqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 04:46:32 -0400
Content-Disposition: inline
In-Reply-To: <20130711051441.GA5189@u109add4315675089e695.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 10:14:43PM -0700, Matt Wilson wrote:
[...]
> Yes, I wanted to get this out since we're talking about multiple
> changes in similar areas.
> 
> > The reason that your patches uses req_cons instead of pre-calculated
> > value is, that value returned by xen_netbk_skb_count_slots is actually
> > *wrong* -- that's what Annie tried to fix in her patch.
> 
> Yes and no. With this patch, the xen_netbk_count_skb_slots() is now
> correct. xen_netbk_count_skb_slots() was under-counting when slots
> were inefficiently consumed. With this patch they match.
> 

This is worth mentioning in the commit message IMHO.

> Since we've had trouble with the counting in the past, I felt like
> using the "real" number of slots here was safer and future-proof.
> 

Fair enough. Worth a comment in the code.

> > After fixing xen_netbk_skb_count_slots, we would need the above snippet
> > (or the snippet I proposed in my RFC patch) to prevent overruning the
> > ring.
> 
> Agreed.
> 
> > So a proper patch to this issue (not couting RX slots correctly causing
> > overrun of the ring) would be the above two aspects combined.
> 
> Yes, I think so.
> 
> > Comments?
> 
> I think that this patch addresses the problem more completely. Annie?
> 
> See also the thread from last August:
>    http://lists.xen.org/archives/html/xen-devel/2012-12/msg00274.html
> 

So now it seems that "turning head in start_new_rx_buffer to flag" part
should also be in the patch as it's actually a fix to match counting in
both functions. The side effect of this change is "improving efficiency
of the ring". This would also worth mentioning in the commit message
IMHO.


Wei.

> --msw
