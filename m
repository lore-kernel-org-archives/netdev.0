From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to
 tcp_info
Date: Wed, 20 May 2015 17:37:11 -0700
Message-ID: <1432168631.4060.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
	 <20150512130855.GA29412@localhost.localdomain>
	 <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555D218D.50509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36175 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbbEUAhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 20:37:13 -0400
Received: by igbpi8 with SMTP id pi8so116469345igb.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 17:37:13 -0700 (PDT)
In-Reply-To: <555D218D.50509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 17:06 -0700, Rick Jones wrote:
> On 05/20/2015 04:35 PM, Eric Dumazet wrote:
> > From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> >
> > This patch tracks the total number of inbound and outbound segments on a
> > TCP socket. One may use this number to have an idea on connection
> > quality when compared against the retransmissions.
> >
> > RFC4898 named these : tcpEStatsPerfSegsIn and tcpEStatsPerfSegsOut
> >
> > These are a 32bit field each and can be fetched both from TCP_INFO
> > getsockopt() if one has a handle on a TCP socket, or from inet_diag
> > netlink facility (iproute2/ss patch will follow)
> 
> I suppose it is far-fetched, but is it a concern that at 100 Gbit/s and 
> 1500 byte MTU the 32 bit segment counter would wrap in something like 
> 500 seconds and change?


Like SNMP counters, applications are responsible to adapt snapshot
intervals and deals with wraps around.

For these counters, applications are probably not interested in absolute
numbers, but deltas every couple of seconds to study the behavior of a
flow during time.

The byte counters are 64bits and shall not overflow.

Anyway, if we can send tcp data at 100Gbits on one flow, I guess we are
doing a terrific job and do not need to tweak TCP stack anymore ;)
