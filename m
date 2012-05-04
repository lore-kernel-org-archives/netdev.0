From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN
 negociation
Date: Fri, 04 May 2012 21:05:59 +0200
Message-ID: <1336158359.3752.382.camel@edumazet-glaptop>
References: <1336144442.3752.348.camel@edumazet-glaptop>
	 <4FA41B5B.5080103@hp.com> <1336155815.3752.365.camel@edumazet-glaptop>
	 <4FA42491.2020104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64478 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497Ab2EDTGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 15:06:05 -0400
Received: by wibhr7 with SMTP id hr7so1674700wib.1
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 12:06:04 -0700 (PDT)
In-Reply-To: <4FA42491.2020104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 11:48 -0700, Rick Jones wrote:
> On 05/04/2012 11:23 AM, Eric Dumazet wrote:
> > On Fri, 2012-05-04 at 11:09 -0700, Rick Jones wrote:
> >> What sort of networks were these?  Any chance it was some sort of
> >> attempt to add ECN to FastOpen?
> >
> > Nothing to do with fastopen.
> >
> > Just take a look at a random http server and sample all SYN packets it
> > receives.
> >
> > Some of them have TOS bits 0 or 1 set, or even both bits set.
> 
> I'll fire-up tcpdump on netperf.org:
> 
> tcpdump -i eth0 -vvv '(tcp[tcpflags] & tcp-syn != 0) && (ip[1] != 0x0)'
> 
> and see what appears.
> 
> rick

of (ip[1] & 3 != 0)


Note that you could catch SYNACK with this filter (if your machine
initiates some active TCP sessions), since SYNACK might have ECT bits,
if some stacks implemented :

http://tools.ietf.org/html/draft-kuzmanovic-ecn-syn-00  ( Adding
Explicit Congestion Notification (ECN) Capability to TCP's SYN/ACK
Packets )

http://tools.ietf.org/id/draft-ietf-tcpm-ecnsyn-04.txt
