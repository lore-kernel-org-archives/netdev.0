From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: e1000_down and tx_timeout worker race cleaning the transmit
 buffers
Date: Fri, 21 Apr 2006 12:00:31 -0700
Message-ID: <1145646031.3843.5.camel@rh4>
References: <1145578214.3195.6.camel@rh4>
 <E1FWlWa-0007hN-00@gondolin.me.apana.org.au>
 <20060421024024.GA29644@gondor.apana.org.au>
 <1145582676.3195.18.camel@rh4>
 <20060421132758.GA26161@gospo.rdu.redhat.com>
 <1145633287.3194.10.camel@rh4>
 <bdfc5d6e0604211301k682b35d1r52a52cd3fec80ddc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, shawvrana@gmail.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:53260 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932385AbWDUUki
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 16:40:38 -0400
To: "Andy Gospodarek" <andy@greyhouse.net>
In-Reply-To: <bdfc5d6e0604211301k682b35d1r52a52cd3fec80ddc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-21 at 16:01 -0400, Andy Gospodarek wrote:

> I just hate to see extra resources used to solve problems that good
> coding can solve (not that my suggestion is necessarily a 'good' one),
> so I was trying to think of a way to resolve this without explicitly
> adding another workqueue.

If you don't want to add another workqueue, then look at tg3, bnx2, and
one of the smc drivers on how to effectively wait for the driver's
workqueue task to finish without deadlocking with linkwatch_event.


