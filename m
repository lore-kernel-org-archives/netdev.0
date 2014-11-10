From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] BUG in xennet_make_frags with paged skb data
Date: Mon, 10 Nov 2014 09:02:35 -0800
Message-ID: <1415638955.9613.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141106214940.GD44162@ubuntu-hedt>
	 <545CA27F.4070400@citrix.com>	<20141110143517.GA74005@ubuntu-hedt>
	 <5460CEA5.3070201@citrix.com> <5460EA45.2080202@linaro.org>
	 <5460EAF1.5020903@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@linaro.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39047 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbaKJRCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 12:02:39 -0500
In-Reply-To: <5460EAF1.5020903@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-10 at 16:42 +0000, David Vrabel wrote:
> On 10/11/14 16:39, Zoltan Kiss wrote:
> > 
> > The BUG_ON suggested by Stefan would be still reasonable:
> > 
> > BUG_ON(((page-compound_head(page))*PAGE_SIZE)+offset+len >
> > PAGE_SIZE<<compound_order(compound_head(page)));
> 
> Well, it wouldn't trigger but I don't think it is useful any more.

Right.

This BUG_ON() does not make sense (its current implementation is
assuming a very precise layout anyway)

If we really wanted some debugging, we would need something more generic
and done in core networking stack, not in a particular driver.
