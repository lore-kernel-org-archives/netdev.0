From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "ipv4: arp announce, arp_proxy and windows ip
 conflict verification"
Date: Tue, 30 Jun 2009 20:10:16 -0700 (PDT)
Message-ID: <20090630.201016.203484460.davem@davemloft.net>
References: <200903011344.45814.denys@visp.net.lb>
	<m1r5x1z5z4.fsf@fess.ebiederm.org>
	<m17hytrvcq.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, denys@visp.net.lb, stable@kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51947
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752808AbZGADKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 23:10:12 -0400
In-Reply-To: <m17hytrvcq.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 30 Jun 2009 19:27:17 -0700

> This reverts commit 73ce7b01b4496a5fbf9caf63033c874be692333f.
> 
> After discovering that we don't listen to gratuitious arps in 2.6.30
> I tracked the failure down to this commit.
> 
> The patch makes absolutely no sense.  RFC2131 RFC3927 and RFC5227.
> are all in agreement that an arp request with sip == 0 should be used
> for the probe (to prevent learning) and an arp request with sip == tip
> should be used for the gratitous announcement that people can learn
> from.
> 
> It appears the author of the broken patch got those two cases confused
> and modified the code to drop all gratuitous arp traffic.  Ouch!
> 
> Cc: stable@kernel.org
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Applied and queued up for -stable, thanks Eric.

To be honest I didn't want to apply that patch, but it seemed
to match up with the RFC in question so I figured I had no
arguments against it :)
