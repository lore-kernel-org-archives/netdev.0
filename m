From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: RE: [PATCH net-next 2/3] qeth: Convert use of __constant_htons to
 htons
Date: Thu, 20 Aug 2015 13:43:56 +0200
Message-ID: <1440071036.685.7.camel@BR9GV9YG.de.ibm.com>
References: <1439972454-64347-1-git-send-email-ubraun@linux.vnet.ibm.com>
	 <1439972454-64347-3-git-send-email-ubraun@linux.vnet.ibm.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB804CD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"ursula.braun@de.ibm.com" <ursula.braun@de.ibm.com>,
	Vaishali Thakkar <vthakkar1994@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:42391 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbbHTLoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 07:44:01 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 20 Aug 2015 12:43:59 +0100
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB804CD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-20 at 10:46 +0000, David Laight wrote:
> From: Ursula Braun
> > Sent: 19 August 2015 09:21
> > In little endian cases, the macro htons unfolds to __swab16 which
> > provides special case for constants. In big endian cases,
> > __constant_htons and htons expand directly to the same expression.
> > So, replace __constant_htons with htons with the goal of getting
> > rid of the definition of __constant_htons completely.
> ...
> > diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
> > index 70eb2f6..ecfe622 100644
> > --- a/drivers/s390/net/qeth_l3_main.c
> > +++ b/drivers/s390/net/qeth_l3_main.c
> > @@ -1887,13 +1887,13 @@ static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
> >  		case QETH_CAST_MULTICAST:
> >  			switch (prot) {
> >  #ifdef CONFIG_QETH_IPV6
> > -			case __constant_htons(ETH_P_IPV6):
> > +			case htons(ETH_P_IPV6):
> 
> I didn't think htons() was 'constant enough' to be used as a case label.
> 
> Using byteswapped constants in a case statement can change it from being
> implemented as a jump table to a branch tree.
> This might be more expensive than byteswapping the value (even on systems
> that don't have cheap byteswap instructions).
> 
> 	David
> 
For big endian systems both __constant_htons(x) and htons(x) are
resolved to ((__force __be16)(__u16)(x)). Thus I do not see a reason to
reject the patch proposal from Vaishali Thakkar.

Ursula
