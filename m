From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1 net-next] xen-netback: remove
 unconditional pull_skb_tail in guest Tx path
Date: Wed, 5 Nov 2014 09:51:20 +0000
Message-ID: <1415181080.11486.63.camel@citrix.com>
References: <1415036346.1411.3.camel@citrix.com>
	 <5457BF80.2000205@citrix.com> <5457C807.5080509@linaro.org>
	 <20141104.161704.1690311989900127361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <zoltan.kiss@linaro.org>, <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <malcolm.crossley@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:21011 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169AbaKEJvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 04:51:50 -0500
In-Reply-To: <20141104.161704.1690311989900127361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-04 at 16:17 -0500, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@linaro.org>
> Date: Mon, 03 Nov 2014 18:23:03 +0000
> 
> > 
> > 
> > On 03/11/14 17:46, David Vrabel wrote:
> >> On 03/11/14 17:39, Ian Campbell wrote:
> >>> On Mon, 2014-11-03 at 17:23 +0000, David Vrabel wrote:
> >>>> From: Malcolm Crossley <malcolm.crossley@citrix.com>
> >>>>
> >>>> Unconditionally pulling 128 bytes into the linear buffer is not
> >>>> required. Netback has already grant copied up-to 128 bytes from the
> >>>> first slot of a packet into the linear buffer. The first slot normally
> >>>> contain all the IPv4/IPv6 and TCP/UDP headers.
> >>>
> >>> What about when it doesn't? It sounds as if we now won't pull up,
> >>> which
> >>> would be bad.
> >>
> >> The network stack will always pull any headers it needs to inspect
> >> (the
> >> frag may be a userspace page which has the same security issues as a
> >> frag with a foreign page).
> > I wouldn't bet my life on this, but indeed it should always happen.
> 
> I would bet my life on it.
> 
> Every protocol demux starts with pskb_may_pull() to pull frag data
> into the linear area, if necessary, before looking at headers.

Then I stand corrected, I was sure this wasn't the case (but my
information could well be a decade out of date...).

Is this also true for things which hit the iptables paths? I suppose
they must necessarily have already been through the protocol demux stage
before iptables would even be able to interpret them as e.g. an IP
packet.

Ian.
