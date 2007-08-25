From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Fri, 24 Aug 2007 20:42:59 -0400
Message-ID: <46CF7B13.3020701@psc.edu>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>	<20070821.212229.82050253.davem@davemloft.net>	<46CC6DD1.5020105@hp.com>	<20070822.132145.90824527.davem@davemloft.net>	<1187906650.4279.16.camel@localhost>	<1187907903.4279.28.camel@localhost>	<46CE0BA1.60206@hp.com> <20070823231820.2ae52cc0.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, hadi@cyberus.ca,
	David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	gaagaan@gmail.com, general@lists.openfabrics.org,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:65404 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbXHYAnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 20:43:11 -0400
In-Reply-To: <20070823231820.2ae52cc0.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Fink wrote:
> Here you can see there is a major difference in the TX CPU utilization
> (99 % with TSO disabled versus only 39 % with TSO enabled), although
> the TSO disabled case was able to squeeze out a little extra performance
> from its extra CPU utilization.  Interestingly, with TSO enabled, the
> receiver actually consumed more CPU than with TSO disabled, so I guess
> the receiver CPU saturation in that case (99 %) was what restricted
> its performance somewhat (this was consistent across a few test runs).


One possibility is that I think the receive-side processing tends to do 
better when receiving into an empty queue.  When the (non-TSO) sender is 
the flow's bottleneck, this is going to be the case.  But when you 
switch to TSO, the receiver becomes the bottleneck and you're always 
going to have to put the packets at the back of the receive queue.  This 
might help account for the reason why you have both lower throughput and 
higher CPU utilization -- there's a point of instability right where the 
receiver becomes the bottleneck and you end up pushing it over to the 
bad side. :)

Just a theory.  I'm honestly surprised this effect would be so 
significant.  What do the numbers from netstat -s look like in the two 
cases?

   -John
