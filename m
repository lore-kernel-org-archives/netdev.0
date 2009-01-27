From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: port bound SAs
Date: Tue, 27 Jan 2009 08:53:47 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02A77519@exch-one.centrify.com>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com><BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:44369 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756577AbZA0Qxu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:53:50 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20090126.222035.100955508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

my inspection of the code shows that the port numbers in the SA do not
get propagated into the right places
in transport mode linux is never aware of the port numbers 
racoon systematically zeros them out during SA setup, but even if i
correct the racoon code to put the port number in it still fails becuase
the port numbers get ignored by the kernel

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Monday, January 26, 2009 10:21 PM
To: Paul Moore
Cc: netdev@vger.kernel.org
Subject: Re: port bound SAs

From: "Paul Moore" <paul.moore@centrify.com>
Date: Mon, 26 Jan 2009 11:21:33 -0800

> A few weeks ago I posted a question to the IETF IPsec group on this
> topic 
> 
> I have 2 SPDs declared saying (transport mode)
> 10.0.0.0/24 port 23 esp
> 10.0.0.0/24 port 80 esp
> 
> I then initiate a connection from that Linux machine to another system
> that has the same logical rules
> port 23 fires up and I get an SA pair. The question is - does that SA
> pair belong to port 23 or not
> If I now connect using port 80 from the same Linux box to the same
peer
> it tries to use the SA already set up for port 23
> The remote system (windows in my test case) drops the packets because
it
> believes that the SA is for port 23 traffic only

Why does the Linux system do this?  The route lookup should, as it's
final IPSEC route lookup action, do an xfrm policy lookup which should
do a selector match and thus not match the port 23 rule.

I can't find the code which would allow the sequence of events
you describe, can you?
