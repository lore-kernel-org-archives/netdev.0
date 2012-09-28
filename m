From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 7/7 net-next] tg3: Change default number of tx rings to 1.
Date: Fri, 28 Sep 2012 10:07:19 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B700E@saturn3.aculab.com>
References: <1348698769-760-7-git-send-email-mchan@broadcom.com><20120927.192345.2124577537241070059.davem@davemloft.net><1348807471.7220.138.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <20120928.004912.1130579693973926556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56848 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751140Ab2I1JJu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 05:09:50 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21535-07 for <netdev@vger.kernel.org>;
 Fri, 28 Sep 2012 10:08:46 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120928.004912.1130579693973926556.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > In the simplest case, assume you have 2 TCP streams running in opposite
> > directions.  The TX traffic (mostly TSO) will hash to one tx ring.  The
> > ACKs for the incoming data on a different TCP connection will hash to
> > another TX ring.  The hardware fetches one complete TSO packet from the
> > first ring (up to 64K data) before servicing the other TX ring.  And
> > when it gets to the other TX ring, it will fetch only one packet (one
> > 64-byte ACK packet in this case) and then immediately switches back to
> > the 1st ring (filled with more TSO packets).  In reality, there may be
> > over 10 ACK packets waiting in the 2nd ring because a lot of incoming
> > data has been received and ACKed during this time.  Because the ACKs are
> > going out so slowly, the incoming throughput slows to a trickle.
> 
> Thanks for the explanation, this is the kind of text that belongs in
> the commit message.  Otherwise the next person who reads the patch,
> like me, will ask why this is being done.

And also in the code somewhere.

	David
