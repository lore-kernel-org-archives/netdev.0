From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Wed, 08 Apr 2015 10:20:10 -0700
Message-ID: <5525634A.10207@hp.com>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr> <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr> <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5009.houston.hp.com ([15.240.92.67]:39908 "EHLO
	g9t5009.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584AbbDHRUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:20:13 -0400
In-Reply-To: <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 10:09 AM, Jan Engelhardt wrote:
> The problem won't manifest with netperf even if run for extended
> period (60 seconds). netperf is probably too smart, exploiting some
> form of parallelism.

Heh - I rather doubt netperf is all that smart.  Unless you use the 
likes of the -T global option to bind netperf/netserver to specific 
CPUs, it will just blythly run wherever the stack/scheduler decides it 
should run.

It is though still interesting you don't see the issue with netperf.  I 
don't know specifically how xinetd-chargen behaves but if it is like the 
chargen of old, I assume that means it is sitting there writing one byte 
at a time to the socket, and perhaps has TCP_NODELAY set.  If you want 
to emulate that with netperf, then something like:

netperf -H <receiver> -t TCP_STREAM -- -m 1 -D

would be the command-line to use.

happy benchmarking,

rick jones
