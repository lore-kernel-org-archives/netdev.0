From: Florin Andrei <florin@andrei.myip.org>
Subject: Re: stateless 1:1 NAT
Date: Wed, 17 Oct 2007 11:14:38 -0700
Message-ID: <4716510E.3090300@andrei.myip.org>
References: <E1IhxQo-0004hF-00@gondolin.me.apana.org.au>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:21534 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756848AbXJQSOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 14:14:46 -0400
Received: from localhost (weiqi.home.local [127.0.0.1])
	by weiqi.home.local (Postfix) with ESMTP id 8C238577094
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 11:14:42 -0700 (PDT)
Received: from weiqi.home.local ([127.0.0.1])
	by localhost (andrei.myip.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id J3GgflX421M7 for <netdev@vger.kernel.org>;
	Wed, 17 Oct 2007 11:14:39 -0700 (PDT)
Received: from valar.sanjose.telcontar.com (unknown [192.168.2.2])
	by weiqi.home.local (Postfix) with ESMTP id 4D0B7576EF8
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 11:14:39 -0700 (PDT)
In-Reply-To: <E1IhxQo-0004hF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Florin Andrei <florin@andrei.myip.org> wrote:
>> I've heard that stateless 1:1 NAT will be possible with the upcoming 
>> 2.6.24 kernel.
>> I'd like to test that feature, but I'm not sure when it will actually be 
>> included. Will it be present in the release candidates for 2.6.24?
>> I just need a somewhat stable kernel tree to play with.
> 
> Yes it will be.

So here's the thing I'm trying to solve.

Gigabit network.
Dual homed firewall, doing 1:1 NAT for a bunch of web servers. Some 
protocols are allowed inbound to the servers (the external, NATed 
addresses).
Firewall is running CentOS 5 (kernel 2.6.18)

I run pktgen on a test machine to generate a whole lot of small UDP 
packets with random source addresses. I send the packets to the 
firewall, to one of the 1:1 NATed addresses, to a port that's blocked by 
the firewall.
Meanwhile, I'm downloading a 2GB file from a web server through the 
firewall, in a while [ 1 ] loop, to monitor the functioning of the firewall.

When I start the UDP flood, the current download is able to finish up, 
but a new one won't start. The firewall has one of the cores pegged at 
100% CPU usage, with a lot of interrupts being generated all the time.
I assume there's something related to conntrack, that's why I want to 
test stateless rules. I assume the firewall has much less work to do if 
it's doing everything stateless, at least at the NAT level.

Is it going to be possible to combine stateless 1:1 NAT with stateful 
filtering?

By the way:
OpenBSD 4.1 as a firewall fails even worse in this test case (it freezes 
instantly).
OpenBSD 4.2 works fine under the UDP flood, as if nothing happened.

-- 
Florin Andrei

http://florin.myip.org/
