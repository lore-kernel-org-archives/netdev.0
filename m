From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vxlan: Fix error that was resulting in VXLAN MTU size
 being 10 bytes too large
Date: Tue, 13 Nov 2012 13:33:53 -0800
Message-ID: <20121113133353.227ec987@nehalam.linuxnetplumber.net>
References: <20121109233354.17208.36271.stgit@gitlad.jf.intel.com>
	<20121113.143719.1473223615602040380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43773 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab2KMVez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 16:34:55 -0500
In-Reply-To: <20121113.143719.1473223615602040380.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Nov 2012 14:37:19 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 09 Nov 2012 15:35:24 -0800
> 
> > This change fixes an issue I found where VXLAN frames were fragmented when
> > they were up to the VXLAN MTU size.  I root caused the issue to the fact that
> > the headroom was 4 + 20 + 8 + 8.  This math doesn't appear to be correct
> > because we are not inserting a VLAN header, but instead a 2nd Ethernet header.
> > As such the math for the overhead should be 20 + 8 + 8 + 14 to account for the
> > extra headers that are inserted for VXLAN.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Applied, thanks for the detailed commit message.

Probably need smarter code there to look at header length requirement
of underlying device as well, maybe someone will be perverse and runn
vxlan over a tunnel or IPoIB.
