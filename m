From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: regression: unregister_netdev() unusably slow
Date: Sun, 24 May 2009 15:21:50 -0400
Message-ID: <20090524192150.GE24757@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43778 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbZEXTu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 15:50:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

I just ran a few L2TP tests against 2.6.30-rc7, and it looks like network 
device deletion has become unusably slow.  At least in 2.6.27.10, deleting 
1000 network interfaces takes less than 2 seconds of real time.  The same 
test run under 2.6.30-rc7 is taking hundreds of seconds to delete 1000 
interfaces at a rate of about 5 per second.  The interfaces all share the 
same local ip address, but each have a single route to a unique client 
ip address.

This is a fairly reasonable use-case, as a single L2TP daemon can be 
terminating thousands of client connections on a single tunnel, and a 
tunnel flap will require tearing down all these interfaces.  I'll work on 
bisecting it, but if someone has any ideas of the source, I'd appreciate 
hearing about it.

		-ben
