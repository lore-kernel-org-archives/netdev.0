From: Lukas Erlacher <erlacher@in.tum.de>
Subject: Re: No SO_BUSY_POLL for UDP?
Date: Wed, 18 Mar 2015 00:51:40 +0100
Message-ID: <5508BE0C.7060103@in.tum.de>
References: <5508AA13.3030401@in.tum.de> <1426634401.11398.245.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out1.informatik.tu-muenchen.de ([131.159.0.8]:46222 "EHLO
	mail-out1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753930AbbCQXvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 19:51:43 -0400
In-Reply-To: <1426634401.11398.245.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2015 12:20 AM, Eric Dumazet wrote:
> 
> busypoll should be available on _connected_ UDP sockets. Otherwise, we
> would have to look all RX queues of the NIC, not a single one.
> 
> Try netperf  -t UDP_RR -- -N -n
> 
>     -n                Use the connected socket for UDP locally
>     -N                Use the connected socket for UDP remotely
> 
> (Although I believe netserver->netperf is ignoring the -N option, that
> is a netperf bug)
> 
> check with ss -a|grep udp
> 

Thank you very much, I was missing that bit of info. With connected
sockets, busy polling works perfectly.

Best,
Lukas Erlacher
