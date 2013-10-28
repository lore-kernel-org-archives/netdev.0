From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RESEND] packet: Deliver VLAN TPID to userspace
Date: Mon, 28 Oct 2013 20:11:14 +0000
Message-ID: <1382991074.3779.22.camel@bwh-desktop.uk.level5networks.com>
References: <87r4bdk8c3.wl%atzm@stratosphere.co.jp>
	 <20131025.185920.1893524127229371162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <atzm@stratosphere.co.jp>, <netdev@vger.kernel.org>,
	<stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46190 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755953Ab3J1ULS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 16:11:18 -0400
In-Reply-To: <20131025.185920.1893524127229371162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 18:59 -0400, David Miller wrote:
> From: Atzm Watanabe <atzm@stratosphere.co.jp>
> Date: Tue, 22 Oct 2013 17:39:40 +0900
> 
> >  struct tpacket_hdr_variant1 {
> >  	__u32	tp_rxhash;
> >  	__u32	tp_vlan_tci;
> > +	__u32	tp_vlan_tpid;
> >  };
> >  
> 
> You cannot do this, the header length is not variable.

Well it is variable to an extent.  This is used as a member of the final
anonymous union member of struct tpacket3_hdr, and the latter is
specified to be tail-padded to a multiple of 16 bytes
(TPACKET_ALIGNMENT).  Since its current size is 36 bytes, I think it can
safely grow by 12 bytes, so long as userland doesn't depend on
getsockopt(..., PACKET_HDRLEN, ...) returning only specific values.

Possibly there should be a separate struct tpacket_hdr_variant2 which
includes the extra member.  Possibly there should also be a status flag
to indicate that this member is present.

> This patch has been submitted several times, each of which you
> have been shown ways in which your changes break userspace in
> one way or another.

I think we established that struct tpacket3_hdr can't grow arbitrarily,
but not that it can't grow at all.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
