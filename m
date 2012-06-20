From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 23:17:56 +0200
Message-ID: <1340227076.4604.1905.camel@edumazet-glaptop>
References: <1340171940.4604.799.camel@edumazet-glaptop>
	 <1340215664.2576.12.camel@bwh-desktop.uk.solarflarecom.com>
	 <1340217604.4604.1569.camel@edumazet-glaptop>
	 <20120620.140121.1603737472432326278.davem@davemloft.net>
	 <20120620140454.36847c65@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56261 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093Ab2FTVSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 17:18:02 -0400
Received: by bkcji2 with SMTP id ji2so6692769bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 14:18:00 -0700 (PDT)
In-Reply-To: <20120620140454.36847c65@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 14:04 -0700, Stephen Hemminger wrote:
> On Wed, 20 Jun 2012 14:01:21 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 20 Jun 2012 20:40:04 +0200
> > 
> > > If someone wants to tune its linux router, he probably already disables
> > > GRO because of various issues with too big packets.
> > > 
> > > GRO adds a significant cost to forwarding path.
> > 
> > No, Ben is right Eric.  GRO decreases the costs, because it means we
> > only need to make one forwarding/netfilter/classification decision for
> > N packets instead of 1.
> 
> GRO is also important for routers that interact with VM's.
> It helps reduce the per-packet wakeup of the guest VM's.

I spoke of mere routers, I was _not_ saying GRO is useless.

In most routers setups I used, I had to disable GRO, because 64Kbytes
packets on output path broke the tc setups (SFQ)

netfilter cost was hardly a problem, once correctly done.
