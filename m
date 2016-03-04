From: Alan Cox <alan@linux.intel.com>
Subject: Re: Sending short raw packets using sendmsg() broke
Date: Fri, 04 Mar 2016 15:54:09 +0000
Message-ID: <1457106849.7064.55.camel@linux.intel.com>
References: <20160225.152628.1230785666614750970.davem@davemloft.net>
	 <1456497874.7064.7.camel@linux.intel.com>
	 <CAF=yD-JOQZZnU6XE9FhEVbxstKmsB-ds58e5v678SiO24VV0+g@mail.gmail.com>
	 <20160226.124645.2123990166666725876.davem@davemloft.net>
	 <CAF=yD-+m09_KS9+SyMZsTES5iLPyVE10F0u6pt4tVeYcDk8=PQ@mail.gmail.com>
	 <1456876822.7064.36.camel@linux.intel.com>
	 <CAF=yD-+mNY0g4A8oWJEWPDeAuucrJX-E1pNd6ABYK+BzmrKvOQ@mail.gmail.com>
	 <CAF=yD-+-QFp=g8BSsxjwwMmMwuHzkEiubZHNuyoLccF7qTs0ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Heikki Hannikainen <hessu@hes.iki.fi>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16605 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756879AbcCDPyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 10:54:17 -0500
In-Reply-To: <CAF=yD-+-QFp=g8BSsxjwwMmMwuHzkEiubZHNuyoLccF7qTs0ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > A quick search for ethhdr in drivers/net/ethernet shows, for
> > instance,
> > bnx2x_select_queue casting skb->data to an ethernet header. Reading
> > nonsense in that particular function is quite safe and given the
> > skbuff layout (skb_shared_info) code will never read beyond an
> > allocated region. But that was just the first occurrence I found.
> > efx_tso_check_protocol is another example.

So would always allocating that much space be a good mitigation in
general, and perhaps then making the logic check validate() IFF
CAP_SYS_RAWIO is not set.

A user with CAP_SYS_RAWIO already has the power to control the device
by banging registers so the check is not a security loss.

Alan
