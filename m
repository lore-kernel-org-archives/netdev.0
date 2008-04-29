From: Rick Jones <rick.jones2@hp.com>
Subject: Re: netperf udp_rr testing hang
Date: Tue, 29 Apr 2008 09:48:31 -0700
Message-ID: <4817515F.4090500@hp.com>
References: <1209109343.28819.37.camel@ymzhang>	<36D9DB17C6DE9E40B059440DB8D95F520507661D@orsmsx418.amr.corp.intel.com>	<1209354200.2873.11.camel@ymzhang> <1209461278.2873.34.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:10503 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276AbYD2Qse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 12:48:34 -0400
In-Reply-To: <1209461278.2873.34.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin wrote:
> I located the root cause.
> kernel is ok. It's an issue of netperf.
> 
> I instrumented kernel and turn on netperf debug to capture more data.
>  As a matter of fact, netserver on the Server1 machine binds ip
> 0.0.0.0 and the port to receive UDP packets, but netperf on Client1
> machine binds ip 192.168.1.164 by bind and remote ip 192.168.1.153 by
> connect. When Server1 sends back a response, it just chooses one ip
> of Server1 as the source ip to send out the packets, because server
> socket just binds 0.0.0.0. So kernel on Client1 just drops the
> packets.
> 
> The fix could be one of them:
> 1) Don't call connect in netperf for UDP testing; But it looks like
> the transactions just pass from one interface, not distributed on the
> 2 interface;
> 2) Pass remote_ip to server by udp_rr_request;
> 
> 1 is more simple.

Odd that this should come-up at this point - the netperf UDP_RR test has 
been operating that way since day one.  It goes backa long way, but I 
believe I did things that way on the premis that a client would 
"connect" to the server IP so it would "know" that the response 
came-back from the server to which the request was sent.

The only thing that _might_ have changed over the years was an explicit 
bind() creaping-in when the bind() used to be implicit with the 
connect() call.   If that is indeed involved, it would be seen by 
running say a, oh, 2.0 version of netperf from the repository.

rick jones
