From: "Paul Moore" <paul.moore@centrify.com>
Subject: port bound SAs
Date: Mon, 26 Jan 2009 11:21:33 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:12931 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752168AbZAZTVd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 14:21:33 -0500
Content-class: urn:content-classes:message
In-Reply-To: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few weeks ago I posted a question to the IETF IPsec group on this
topic 

I have 2 SPDs declared saying (transport mode)
10.0.0.0/24 port 23 esp
10.0.0.0/24 port 80 esp

I then initiate a connection from that Linux machine to another system
that has the same logical rules
port 23 fires up and I get an SA pair. The question is - does that SA
pair belong to port 23 or not
If I now connect using port 80 from the same Linux box to the same peer
it tries to use the SA already set up for port 23
The remote system (windows in my test case) drops the packets because it
believes that the SA is for port 23 traffic only

The small amount of feedback I got was that the SA should belong to port
23 and that Linux seems to be doing the wrong thing

I can change the problem a bit by adding require to the SPD entry. There
are several things wrong with that though

a) it should not be necessary
b) I get a lot of SAs
c) I can no longer say that the SPD is optional (that's a separate
topic, the overloading of 2 orthogonal concepts onto a single value)
d) I am still worried that it does not work correctly in all cases

