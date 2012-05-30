From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Strange latency spikes/TX network stalls on Sun Fire X4150(x86) and e1000e
Date: Wed, 30 May 2012 11:52:29 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F31@saturn3.aculab.com>
References: <1338367231.2760.125.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Tom Herbert" <therbert@google.com>,
	"Denys Fedoryshchenko" <denys@visp.net.lb>,
	<netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<davem@davemloft.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Hiroaki SHIMODA" <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33148 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752416Ab2E3KxW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 06:53:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24671-06 for <netdev@vger.kernel.org>;
 Wed, 30 May 2012 11:53:17 +0100 (BST)
Content-class: urn:content-classes:message
In-reply-to: <1338367231.2760.125.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > +	num_queued = dql->num_queued;
> 
> 
> I suggest :
> 
> 	num_queued = ACCESS_ONCE(dql->num_queued);
> 	
> Or else compiler is free to do whatever he wants.

Or make the structure member volatile, then the
compiler can only read it once.
Probably worth while if the value is expected to
be read like that.

	David
