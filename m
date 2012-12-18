From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: inaccurate packet scheduling
Date: Tue, 18 Dec 2012 10:43:50 -0800
Message-ID: <20121218104350.6aec09fd@nehalam.linuxnetplumber.net>
References: <20121218150407.GB1533@minipsycho.orion>
	<e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
	<20121218175409.GA1690@minipsycho.orion>
	<CANn89iJdROkJ+dZgfDB9wPpQ3wXdUHK7SX=C2iUbHxwh9=5orw@mail.gmail.com>
	<20121218184036.GB1690@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	jhs@mojatatu.com, davem@davemloft.net, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49124 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755448Ab2LRSpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 13:45:51 -0500
In-Reply-To: <20121218184036.GB1690@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Dec 2012 19:40:36 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Tue, Dec 18, 2012 at 07:06:53PM CET, edumazet@google.com wrote:
> >> No such messages in log
> >>
> >>>Also turn off TSO since it screws up any form of rate control.
> >>
> >> Turning off TSO did not help. However, turning off scatter-gather
> >> helped, on both HP DL360G8 (igb) and IBM JS22 (ehea).
> >>
> >
> >Think to also disable GSO
> 
> On rhel6 kernel (2.6.32-based) I have to disable GSO as well.
> 
> The question is: Is this a bug or is it mandatory to get this offload
> disabled in order to TBF to be working correctly?
> 
> Thanks a bunch.
> 
> Jiri
> 
> >
> >Alternatively, you can use "mtu 65536" to allow TBF to send packets
> >bigger than 2048 bytes

It is really a bug. The packet schedulers mostly assume that a single
skb results in a single packet, and that the skb->len equals the size
of the packet on the wire.
