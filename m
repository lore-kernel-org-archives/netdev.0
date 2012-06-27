From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 10:02:17 +0200
Message-ID: <1340784137.26242.5.camel@edumazet-glaptop>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <1340778733.2028.110.camel@localhost>
	 <20120626.235423.588696200884989114.davem@davemloft.net>
	 <1340781845.2028.133.camel@localhost>
	 <1340782216.10893.427.camel@edumazet-glaptop>
	 <1340783670.2028.141.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63780 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756138Ab2F0ICX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:02:23 -0400
Received: by eaak11 with SMTP id k11so250820eaa.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 01:02:22 -0700 (PDT)
In-Reply-To: <1340783670.2028.141.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 09:54 +0200, Jesper Dangaard Brouer wrote:

> Well, that would lead to parallel SYN processing, wouldn't it?

I think we already discussed of the current issues of current code.

Telling people to spread SYN to several cpus is a good way to have a
freeze in case of synflood, because 15 cpus are busy looping while one
is doing progress.

Thats why Intel felt the need of a hardware filter to direct all SYN
packets on a single queue.
