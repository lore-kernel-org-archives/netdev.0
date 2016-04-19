From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 17:50:45 +0100
Message-ID: <571661E5.7010304@solarflare.com>
References: <5716338E.4050003@solarflare.com>
 <5716347D.3030808@solarflare.com>
 <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:17998 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753351AbcDSQuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 12:50:54 -0400
In-Reply-To: <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/16 15:50, Eric Dumazet wrote:
> The main problem in UDP stack today is having to lock the socket because
> of the dumb forward allocation problem.
I'm not quite sure what you're referring to here, care to educate me?

> Are you really going to provide
> a list of skbs up to _one_ UDP socket ?
In principle we should be able to take it that far, yes.  AFAICT the
socket already has a receive queue that we end up appending the packet
to (and which I presume the recvmsg() syscall pulls from), I don't see
why we couldn't just splice a list of skbs on the end rather than
appending them one by one.  Thus amortising looking up the socket.
