From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN
 negociation
Date: Fri, 04 May 2012 20:23:35 +0200
Message-ID: <1336155815.3752.365.camel@edumazet-glaptop>
References: <1336144442.3752.348.camel@edumazet-glaptop>
	 <4FA41B5B.5080103@hp.com>
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
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44010 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab2EDSXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 14:23:45 -0400
Received: by bkcji2 with SMTP id ji2so2448196bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 11:23:43 -0700 (PDT)
In-Reply-To: <4FA41B5B.5080103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 11:09 -0700, Rick Jones wrote:
> On 05/04/2012 08:14 AM, Eric Dumazet wrote:
> > From: Eric Dumazet<edumazet@google.com>
> >
> > It appears some networks play bad games with the two bits reserved for
> > ECN. This can trigger false congestion notifications and very slow
> > transferts.
> >
> > Since RFC 3168 (6.1.1) forbids SYN packets to carry CT bits, we can
> > disable TCP ECN negociation if it happens we receive mangled CT bits in
> > the SYN packet.
> 
> What sort of networks were these?  Any chance it was some sort of 
> attempt to add ECN to FastOpen?

Nothing to do with fastopen.

Just take a look at a random http server and sample all SYN packets it
receives.

Some of them have TOS bits 0 or 1 set, or even both bits set.
