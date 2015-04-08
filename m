From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Wed, 8 Apr 2015 19:09:26 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>  <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr> <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares41.inai.de ([46.4.122.207]:55494 "EHLO ares41.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753727AbbDHRJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 13:09:27 -0400
In-Reply-To: <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2015-04-07 21:49, Eric Dumazet wrote:
>> On Tuesday 2015-04-07 04:48, Eric Dumazet wrote:
>> >On Tue, 2015-04-07 at 00:45 +0200, Jan Engelhardt wrote:
>> >> I have here a Linux 3.19(.0) system where activated TSO on a veth slave 
[and now also 3.19.3]
>> >> device makes IPv4-TCP transfers going into that veth-connected container 
>> >> progress slowly.
>> >
>> >Nothing comes to mind. It would help if you could provide a script to
>> >reproduce the issue.
>> 
>> It seems IPsec is *also* a requirement in the mix.
>> Anyhow, script time!
>
>I tried your scripts, but the sender does not use veth ?

I was finally able to reproduce it reliably, and with just one 
machine/kernel instance (and a number of containers of course).

I have uploaded the script mix to
	http://inai.de/files/tso-1.tar.xz
There is a demo screencast at
	http://inai.de/files/tso-1.mkv

>From the script collection, one can run t-all-init to setup the
network, then t-chargen-server (stays in foreground), and on another
terminal then t-chargen-client. Alternatively, the combination
t-zero-{server,client}. It appears that it has to a simple
single-threaded, single-connection, single-everything transfer.

The problem won't manifest with netperf even if run for extended
period (60 seconds). netperf is probably too smart, exploiting some
form of parallelism.

Oh, and if the transfer rate is absolutely *zero* (esp. for 
xinetd-chargen), that just means that it attempts DNS name resolution. 
Just wait a few seconds in that case for the transfer to start.
