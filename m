From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCHv1 net-next] xen-netback: remove unconditional
 pull_skb_tail in guest Tx path
Date: Wed, 5 Nov 2014 09:53:05 +0000
Message-ID: <1415181185.11486.65.camel@citrix.com>
References: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>
	 <20141104.164113.2265592775058059992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <david.vrabel@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<malcolm.crossley@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50679 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbaKEJxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 04:53:08 -0500
In-Reply-To: <20141104.164113.2265592775058059992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-04 at 16:41 -0500, David Miller wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Mon, 3 Nov 2014 17:23:51 +0000
> 
> > From: Malcolm Crossley <malcolm.crossley@citrix.com>
> > 
> > Unconditionally pulling 128 bytes into the linear buffer is not
> > required. Netback has already grant copied up-to 128 bytes from the
> > first slot of a packet into the linear buffer. The first slot normally
> > contain all the IPv4/IPv6 and TCP/UDP headers.
> > 
> > The unconditional pull would often copy frag data unnecessarily.  This
> > is a performance problem when running on a version of Xen where grant
> > unmap avoids TLB flushes for pages which are not accessed.  TLB
> > flushes can now be avoided for > 99% of unmaps (it was 0% before).
> > 
> > Grant unmap TLB flush avoidance will be available in a future version
> > of Xen (probably 4.6).
> > 
> > Signed-off-by: Malcolm Crossley <malcolm.crossley@citrix.com>
> > Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> 
> Now that this has been discussed a bit, it is possible to get an ack or two?

I'd like to see the commit message expanded to explain why this isn't
introducing a (security) bug by not pulling enough stuff into the header
(IOW the conclusion of the discussion).

Ian.
