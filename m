From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH] bnx2x: fix panic when TX ring is full
Date: Sat, 16 Jun 2012 07:40:29 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
References: <1339616716.22704.661.camel@edumazet-glaptop>
 <20120615.153049.103988387813257203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"evansr@google.com" <evansr@google.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Merav Sicron" <meravs@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"willemb@google.com" <willemb@google.com>,
	"thruby@google.com" <thruby@google.com>
To: "'David Miller'" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2693 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025Ab2FPHlD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2012 03:41:03 -0400
In-Reply-To: <20120615.153049.103988387813257203.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric and Tomas

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: Saturday, June 16, 2012 1:31 AM
> To: eric.dumazet@gmail.com
> Cc: netdev@vger.kernel.org; therbert@google.com; evansr@google.com;
> Eilon Greenstein; Merav Sicron; Yaniv Rosner; willemb@google.com;
> thruby@google.com
> Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
> 
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 13 Jun 2012 21:45:16 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> >
> > There is a off by one error in the minimal number of BD in
> > bnx2x_start_xmit() and bnx2x_tx_int() before stopping/resuming tx
> queue.
> >
> > A full size GSO packet, with data included in skb->head really needs
> > (MAX_SKB_FRAGS + 4) BDs, because of bnx2x_tx_split()
> >
> > This error triggers if BQL is disabled and heavy TCP transmit traffic
> > occurs.
> >
> > bnx2x_tx_split() definitely can be called, remove a wrong comment.
> >
> > Reported-by: Tomas Hruby <thruby@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>

Theoretically a can't see how we can reach the case with 4 BDs required apart of frags,
Usually we need 2, when split invoked 3:
1.Start
2.Start(split)
3.Parsing
+ Frags

Next pages descriptors and 2 extras for full indication are not counted as available.

Practically I'm running the traffic for more then a day without hitting the panic.

Can you describe the scenario you reproduced this in details? And which code has paniced? 

Thanks
 
> I got tired of waiting for the Broadcom "maintainers" to review this, so I just
> applied it to 'net', thanks Eric.
