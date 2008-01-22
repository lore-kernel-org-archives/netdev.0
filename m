From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression	in	2.6.24-rc6,	comparing
 with 2.6.22
Date: Tue, 22 Jan 2008 10:36:33 -0800
Message-ID: <479637B1.5000706@hp.com>
References: <1199871330.3298.132.camel@ymzhang>	<1200043854.3265.24.camel@ymzhang>  <4787ADDA.7090602@hp.com>	<1200280292.3151.24.camel@ymzhang>  <478B9FE0.3040801@hp.com>	<1200979482.3151.103.camel@ymzhang> <1200982039.3151.120.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:46900 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbYAVSgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 13:36:35 -0500
In-Reply-To: <1200982039.3151.120.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When parsing the -P option in scan_socket_args() of src/nettest_bsd.c, 
netperf is using "break_args()" from src/netsh.c which indeed if the 
command line says "-P 12345" will set both the local and remote port 
numbers to 12345.  If instead you were to say "-P 12345,"  it will use 
12345 only for the netperf side.  If you say "-P ,12345" it will use 
12345 only for the netserver side.  To set both sides at once to 
different values it would be "-P 12345,54321"

In theory, send_udp_rr() in src/nettest_bsd.c (or I suppose 
scan_socket_args() could have more code added to it to check for a UDP 
test over loopback, but probably needs to be a check for any local IP, 
and unless this becomes something bigger than "Doctor! Doctor! It hurts 
when I do this!" :) I'm inclined to leave it as caveat benchmarker and 
perhaps some additional text in the manual.

rick jones
