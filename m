From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [RFC] skb align patch
Date: Wed, 23 Sep 2009 01:47:48 -0400
Message-ID: <20090923054748.GA24045@bombadil.infradead.org>
References: <4AB71980.4020208@gmail.com> <20090921213011.704e0594@nehalam> <4AB84295.3050509@gmail.com> <20090921.222940.258576265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	jesse.brandeburg@gmail.com, hawk@diku.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52567 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbZIWFrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 01:47:48 -0400
Content-Disposition: inline
In-Reply-To: <20090921.222940.258576265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2009 at 10:29:40PM -0700, David Miller wrote:
> The alignment in this patch is a real big deal for 64 byte forwarding
> tests, where the entire packet is a whole PCI-E cacheline.  But not
> if it isn't aligned properly.

As I pointed out to Herbert already, this alignment change may actually
make things worse or even break things as long as compare_ether_header()
used in __napi_gro_receive() expects the IP header to be aligned to 4
bytes. That can be fixed of course, just wanted to mention it.
