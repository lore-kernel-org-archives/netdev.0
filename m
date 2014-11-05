From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1 net-next] xen-netback: remove
 unconditional pull_skb_tail in guest Tx path
Date: Wed, 5 Nov 2014 10:53:28 +0000
Message-ID: <1415184808.11486.82.camel@citrix.com>
References: <1415036346.1411.3.camel@citrix.com>
		 <5457BF80.2000205@citrix.com> <5457C807.5080509@linaro.org>
		 <20141104.161704.1690311989900127361.davem@davemloft.net>
	 <1415137397.25370.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <545A000D.8070808@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <zoltan.kiss@linaro.org>,
	<netdev@vger.kernel.org>, <malcolm.crossley@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:36801 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbaKEKxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 05:53:31 -0500
In-Reply-To: <545A000D.8070808@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 10:46 +0000, David Vrabel wrote:
> On 04/11/14 21:43, Eric Dumazet wrote:
> > On Tue, 2014-11-04 at 16:17 -0500, David Miller wrote:
> > 
> > 
> >>
> >> Every protocol demux starts with pskb_may_pull() to pull frag data
> >> into the linear area, if necessary, before looking at headers.
> > 
> > eth_get_headlen() might be relevant as well, to perform a single copy of
> > exactly all headers.
> 
> In netback's case we need an estimate of the header length before
> reading any of the packet, since peeking at any frag would prevent any
> TLB flush avoidance.
> 
> It might be useful to use eth_get_headlen() to adjust the estimate at
> runtime, but for now the fixed amount of 128 bytes is simple and seems
> good enough.

I think what Eric meant was that having done the 128 copy you could call
eth_get_headlen which in the common case should be a nop but would
ensure you always had the headers in the linear area for the uncommon
case.

It looks like the difference compared with skb_checksum_setup is that
eth_get_headlen deals with L4 too whereas skb_checksum_setup only goes
to L3 (and then only for some subset of protocols with checksums).

Ian.
