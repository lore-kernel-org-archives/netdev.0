From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 09 Jun 2014 09:15:02 -0700
Message-ID: <1402330502.3645.378.camel@edumazet-glaptop2.roam.corp.google.com>
References: <539319F6.2090907@cogentembedded.com>
	 <1402151680-11434-1-git-send-email-per.hurtig@kau.se>
	 <1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
	 <539413BA.7060903@kau.se>
	 <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
	 <5395B2FC.3070205@kau.se>
	 <1402324388.3645.359.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5395C7E9.4050406@kau.se>
	 <1402326259.3645.374.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5395D937.5060801@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Anna =?ISO-8859-1?Q?Brunstr=F6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:35747 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaFIQPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 12:15:05 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so4994338pbb.8
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 09:15:04 -0700 (PDT)
In-Reply-To: <5395D937.5060801@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 17:56 +0200, Per Hurtig wrote:

> 
> Ok, I guess you mean that the retransmission was not fast enough? But 
> will the same not happen if the original FIN is not lost and triggers a 
> SACK (i.e., if the two last data segments are still lost)?

Yes, I'd like to understand why Nandita specifically added the original
test. In her tests, fast retransmit was not really effective.

Running packetdrill in a separate container gives me these interesting
counters :

# nstat
#kernel
IpInReceives                    4                  0.0
IpInDelivers                    4                  0.0
IpOutRequests                   5                  0.0
TcpPassiveOpens                 1                  0.0
TcpInSegs                       4                  0.0
TcpOutSegs                      10                 0.0
TcpRetransSegs                  2                  0.0
TcpExtTCPPureAcks               3                  0.0
TcpExtTCPSackRecovery           1                  0.0
TcpExtTCPFastRetrans            1                  0.0
TcpExtTCPLossProbes             1                  0.0
TcpExtTCPSackRecoveryFail       1                  0.0
TcpExtTCPSackShiftFallback      1                  0.0
TcpExtTCPRetransFail            4                  0.0   <<<< HERE >>>
TcpExtTCPOrigDataSent           9                  0.0
IpExtInOctets                   184                0.0
IpExtOutOctets                  9212               0.0
IpExtInNoECTPkts                4                  0.0

I guess we need to understand why the retransmit is in error.

I am investigating.
