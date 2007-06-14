From: David Gundersen <gundy@iinet.net.au>
Subject: Re: Realtek r8168 slow outbound transfer -  potential fix/workaround
Date: Fri, 15 Jun 2007 00:57:45 +1000
Message-ID: <46715769.9060101@iinet.net.au>
References: <4670032C.7010803@iinet.net.au> <20070613231124.GC22521@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from customer-domains.icp-qv1-irony14.iinet.net.au ([203.59.1.169]:27194
	"EHLO customer-domains.icp-qv1-irony14.iinet.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749AbXFNO5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 10:57:36 -0400
In-Reply-To: <20070613231124.GC22521@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> What is the value of the MTU for your 8168 device ?

Hi Francois,

The MTU for the adapter is set at the default of 1500.

A bit more background on how I came across this might be in order.  I 
noticed it when performing very simple SQL queries against a postgres 
database on my server.  I captured the traffic on an XP client machine 
using wireshark and on the linux server with tcpdump. I noticed that 
although the linux server claimed to have sent 2 reply packets, XP was 
seeing only the first.

What got me thinking was the fact that the time between the first and 
second response packets from postgres was 0.000005 seconds (according to 
the tcpdump timestamps).  Another 0.4 seconds after that a retry was 
attempted and the packet managed to make it though to the windows 
client.  I started wondering if there might be something going on with 
tightly spaced packets and that's how I ended up checking the NPQ flag. 
  (I also looked into increasing the default interframe gap between 
packets, but that didn't seem to help).

I'm happy to help with additional information including the packet 
captures if you'd like to take a look.

Also, I realised after I posted that first message that having a minimum 
udelay of 25us in that delay loop was probably a bit foolish.  I guess I 
was just so happy to have found something that worked for me that I 
needed to get it off my chest before thinking it through fully.  The 
udelay(25) ends up increasing the minimum inter-frame gap way beyond 
what should be reasonable.    I haven't had a good chance to test this 
yet, but I tried dropping the udelay(25) and using ndelay(10) instead 
and it appeared to load the cpu less that way.


Regards,
Dave.
