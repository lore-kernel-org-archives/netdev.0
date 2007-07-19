From: andrei radulescu-banu <iubica2@yahoo.com>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 14:38:20 -0700 (PDT)
Message-ID: <930446.33248.qm@web56601.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web56601.mail.re3.yahoo.com ([66.196.97.45]:34223 "HELO
	web56601.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752109AbXGSViW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 17:38:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During debugging, I noticed that dev_queue_xmit() is called twice for tx vlan frames. This results in a frame being passed twice to a packet socket bound to 'any' interface. If the packet socket is bound to a specific interface, though, it will get only one copy of the tx frame, which is good.

In more detail: suppose we're tx'ing a frame, and the route table lookup yields a vlan outgoing device eth0.2. dev_queue_xmit() is called, which calls dev_queue_xmit_nit() for dev = eth0.2 then dev->hard_start_xmit() for dev = eth0.2. 

The latter call gets into the vlan layer, which attaches the vlan id 2 (accelerated or not... in my e1000 case accelerated) then calls dev_queue_xmit() again. This time around dev_queue_xmit_nit() is called for dev = eth0, and dev->hard_start_xmit() actually calls the ethernet driver.

The net result is that dev_queue_xmit_nit() is called twice, once for dev=eth0.2 then for dev=eth0.



      ____________________________________________________________________________________
Shape Yahoo! in your own image.  Join our Network Research Panel today!   http://surveylink.yahoo.com/gmrs/yahoo_panel_invite.asp?a=7 


