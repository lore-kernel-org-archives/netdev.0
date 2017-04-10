From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/7] s390/qeth: improve endianness handling
Date: Mon, 10 Apr 2017 15:22:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFCAB25@AcuExch.aculab.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
 <20170405084015.35772-6-ubraun@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFC85F3@AcuExch.aculab.com>
 <8056aa76-8e2d-805e-1037-927714e9bfab@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "jwi@linux.vnet.ibm.com" <jwi@linux.vnet.ibm.com>,
        "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
        "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
        "raspl@linux.vnet.ibm.com" <raspl@linux.vnet.ibm.com>,
        Hans Wippel <hwippel@linux.vnet.ibm.com>,
        "Julian Wiedmann" <jwi@linux.vnet.ibm.com>
To: 'Ursula Braun' <ubraun@linux.vnet.ibm.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:62227 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752841AbdDJPWT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:22:19 -0400
In-Reply-To: <8056aa76-8e2d-805e-1037-927714e9bfab@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun
> Sent: 07 April 2017 13:33
> On 04/07/2017 01:25 PM, David Laight wrote:
> > From: Ursula Braun
> >> Sent: 05 April 2017 09:40
> >> From: Hans Wippel <hwippel@linux.vnet.ibm.com>
> >>
> >> Avoid endianness warnings reported by sparse by (1) using endianness
> >> conversions for assigning and using network packet fields, and (2)
> >> removing unnecessary endianness conversions from qeth_l3_rebuild_skb. No
> >> functional changes.
> >>
> >> Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
> >> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> >> ---
> >>  drivers/s390/net/qeth_core.h      |  4 ++--
> >>  drivers/s390/net/qeth_core_main.c | 11 +++++-----
> >>  drivers/s390/net/qeth_l3_main.c   | 46 +++++++++++++++++++--------------------
> >>  drivers/s390/net/qeth_l3_sys.c    |  4 ++--
> >>  4 files changed, 33 insertions(+), 32 deletions(-)
> >>
> >> diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
> >> index 22aa2cd..6764ab9 100644
> >> --- a/drivers/s390/net/qeth_core.h
> >> +++ b/drivers/s390/net/qeth_core.h
> >> @@ -844,9 +844,9 @@ static inline int qeth_get_ip_version(struct sk_buff *skb)
> >>  {
> >>  	__be16 *p = &((struct ethhdr *)skb->data)->h_proto;
> >>
> >> -	if (*p == ETH_P_8021Q)
> >> +	if (be16_to_cpu(*p) == ETH_P_8021Q)
> >>  		p += 2;
> >> -	switch (*p) {
> >> +	switch (be16_to_cpu(*p)) {
> >>  	case ETH_P_IPV6:
> >
> > These are definitely 'functional changes' on LE systems.
> s390 is Big Endian; thus the change is basicly a NOP.

> The only purpose of this kind of patches is getting rid
> of sparse warnings with our code.

Then say so in the commit message....

What you are really doing is fixing the code in case anyone tries
to use it on a LE system.

	David
