From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 10:46:32 -0800
Message-ID: <45EDB708.1010103@hp.com>
References: <45EBFD13.1060106@symas.com>	<200703051528.02564.dada1@cosmosbay.com> <45ED32CA.5080709@symas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Howard Chu <hyc@symas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:39247 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966011AbXCFSqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:46:36 -0500
In-Reply-To: <45ED32CA.5080709@symas.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This is probably not something that happens in real world deployments. I 
> But it's not 60,000 concurrent connections, it's 60,000 within a 2 
> minute span.

Sounds like a case of Doctor! Doctor! It hurts when I do this.

> 
> I'm not saying this is a high priority problem, I only encountered it in 
> a test scenario where I was deliberately trying to max out the server.
> 
>>> Ideally the 2MSL parameter would be dynamically adjusted based on the
>>> route to the destination and the weights associated with those routes.
>>> In the simplest case, connections between machines on the same subnet
>>> (i.e., no router hops involved) should have a much smaller default value
>>> than connections that traverse any routers. I'd settle for a two-level
>>> setting - with no router hops, use the small value; with any router hops
>>> use the large value.

With transparant bridging, nobody knows how long the datagram may be out 
there.  Admittedly, the chances of a datagram living for a full two 
minutes these days is probably nil, but just being in the same IP subnet 
doesn't really mean anything when it comes to physical locality.

> It's a combination of 2MSL and /proc/sys/net/ipv4/ip_local_port_range - 
> on my system the default port range is 32768-61000. That means if I use 
> up 28232 ports in less than 2MSL then everything stops. netstat will 
> show that all the available port numbers are in TIME_WAIT state. And 
> this is particularly bad because while waiting for the timeout, I can't 
> initiate any new outbound connections of any kind at all - telnet, ssh, 
> whatever, you have to wait for at least one port to free up. 
> (Interesting denial of service there....)

SPECweb benchmarking has had to deal with the issue of attempted 
TIME_WAIT reuse going back to 1997.  It deals with it by not relying on 
the client's configured local/anonymous/ephemeral port number range and 
instead making explicit bind() calls in the (more or less) entire unpriv 
port range (actually it may just be from 5000 to 65535 but still)

Now, if it weren't necessary to fully randomize the ISNs, the chances of 
a successful transition from TIME_WAIT to ESTABLISHED might be greater, 
but going back to the good old days of more or less purly clock driven 
ISN's isn't likely.

rick jones
