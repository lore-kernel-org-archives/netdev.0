From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH] XFRM: SPD auditing fix to include the
	netmask/prefix-length
Date: Fri, 30 Nov 2007 09:16:43 -0600
Message-ID: <1196435803.2488.35.camel@faith.austin.ibm.com>
References: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net>
	 <20071129103459.GD22537@gondor.apana.org.au>
	 <200711290845.46623.paul.moore@hp.com>
	 <200711300951.48964.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, Joy Latten <latten@us.ibm.com>,
	Steve Grubb <sgrubb@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:59594 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759951AbXK3PRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 10:17:37 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAUFHTg0022234
	for <netdev@vger.kernel.org>; Fri, 30 Nov 2007 10:17:29 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAUFHTnO129154
	for <netdev@vger.kernel.org>; Fri, 30 Nov 2007 10:17:30 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAUFHTUf031264
	for <netdev@vger.kernel.org>; Fri, 30 Nov 2007 10:17:29 -0500
In-Reply-To: <200711300951.48964.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-30 at 09:51 -0500, Paul Moore wrote:
> On Thursday 29 November 2007 8:45:46 am Paul Moore wrote:
> > On Thursday 29 November 2007 5:34:59 am Herbert Xu wrote:
> > > On Mon, Nov 26, 2007 at 07:55:12PM +0000, Paul Moore wrote:
> > > > Currently the netmask/prefix-length of an IPsec SPD entry is not
> > > > included in any of the SPD related audit messages.  This can cause a
> > > > problem when the audit log is examined as the netmask/prefix-length is
> > > > vital in determining what network traffic is affected by a particular
> > > > SPD entry. This patch fixes this problem by adding two additional
> > > > fields, "src_prefixlen" and "dst_prefixlen", to the SPD audit messages
> > > > to indicate the source and destination netmasks.  These new fields are
> > > > only included in the audit message when the netmask/prefix-length is
> > > > less than the address length, i.e. the SPD entry applies to a network
> > > > address and not a host address.
> > >
> > > Any reason why we don't just always include them?
> >
> > The audit folks seem to be very sensitive to the size/length of the audit
> > messages, they prefer they be as small as possible.  I thought that one way
> > to save space would be to only print the prefix length information when the
> > address referred to a network and not a single host.
> >
> > Would you prefer it if the prefix length information was always included in
> > the audit message?  Joy?  Audit folks?
> 
> Steve and/or Joy, could we get a verdict on this issue?  The lack of a netmask 
> in the SPD audit messages is pretty serious so I'd like to see this fixed as 
> soon as possible.
> 
I think Steve may be able to answer this much better than I can in 
regards to audit. In my opinion having the netmask is good.

regards,
Joy
