From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: What's the right way to use a *large* number of source
 addresses?
Date: Fri, 23 May 2014 12:49:24 +0200
Message-ID: <DUB123-W366C1804B97909DA64C0F9ED3E0@phx.gbl>
References: <6zlhtsvnqp.fsf@southpole.se>,<20140523101144.GH24523@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jonas Bonn <jonas@southpole.se>
To: Florian Westphal <fw@strlen.de>,
	=?iso-8859-1?B?TmllbHMgTfZsbGVy?= <nisse@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s24.dub0.hotmail.com ([157.55.2.99]:29050 "EHLO
	dub0-omc4-s24.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752889AbaEWKt0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 06:49:26 -0400
In-Reply-To: <20140523101144.GH24523@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 3. Just set the desired local address with the bind call. Currently,
>> this gives an EADDRNOTAVAIL error, so the first step would be some
>> option to allow arbitrary source addresses.
>
> See 'Making non-local sockets work' in Documentation/networking/tproxy.txt


Yes, its a simple as setting IP_FREEBIND and then binding to the specific
source IP.

setsockopt(fd, SOL_IP, IP_FREEBIND, &one, sizeof(one))


You don't need to specify the interface. Just make sure your network
routes the return traffic back to your box.

Works for IPv6 as well (3.3+).



Lukas

 		 	   		  