From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] gre: Fix MTU sizing check for gretap tunnels
Date: Thu, 11 Jul 2013 15:45:02 -0700
Message-ID: <1373582702.4600.85.camel@edumazet-glaptop>
References: <20130711201152.8775.40579.stgit@ahduyck-hc1.jf.intel.com>
	 <CALnjE+p3tqNO9Fbn=+LLtL8VvfvSQyOLDZoFRvGFTXgJzHKqhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, jesse@nicira.com, davem@davemloft.net
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:56883 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756466Ab3GKWpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 18:45:05 -0400
Received: by mail-ob0-f176.google.com with SMTP id v19so10430308obq.7
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 15:45:05 -0700 (PDT)
In-Reply-To: <CALnjE+p3tqNO9Fbn=+LLtL8VvfvSQyOLDZoFRvGFTXgJzHKqhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-11 at 15:24 -0700, Pravin Shelar wrote:
> On Thu, Jul 11, 2013 at 1:12 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
> > This change fixes an MTU sizing issue seen with gretap tunnels when non-gso
> > packets are sent from the interface.
> >
> > In my case I was able to reproduce the issue by simply sending a ping of
> > 1421 bytes with the gretap interface created on a device with a standard
> > 1500 mtu.
> >
> > This fix is based on the fact that the tunnel mtu is already adjusted by
> > dev->hard_header_len so it would make sense that any packets being compared
> > against that mtu should also be adjusted by hard_header_len and the tunnel
> > header instead of just the tunnel header.
> >
> we can simplify code by not doing dev->hard_header_len adjustment to tunnel-mtu.
> 
> And right thing would be adjusting tunnel-mtu according to rt->dst.dev
> header-len so that we get mtu for out going path.

What's the mtu value we want to put in the ICMP message ?
