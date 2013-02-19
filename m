From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] b43: Increase number of RX DMA slots
Date: Tue, 19 Feb 2013 09:42:28 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com>
References: <1361156480-32566-1-git-send-email-Larry.Finger@lwfinger.net> <20130219.005206.397289032011003833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linville@tuxdriver.com>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <bittorf@bluebottle.com>,
	<stable@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40927 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932448Ab3BSJnS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 04:43:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26166-03 for <netdev@vger.kernel.org>;
 Tue, 19 Feb 2013 09:43:15 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20130219.005206.397289032011003833.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Bastian Bittorf reported that some of the silent freezes on a Linksys WRT54G
> > were due to overflow of the RX DMA ring buffer, which was created with 64
> > slots. That finding reminded me that I was seeing similar crashed on a netbook,
> > which also has a relatively slow processor. After increasing the number of
> > slots to 128, runs on the netbook that previously failed now worked; however,
> > I found that 109 slots had been used in one test. For that reason, the number
> > of slots is being increased to 256.

Surely the driver should work even if all the RX buffers get filled?
Increasing the number of buffers is just hiding the issue.
A burst of 300 back to back small packets probably fills the 256 slots.

I realise that dropping frames isn't ideal, and that small numbers
of buffers can make it impossible to receive long fragmented IP
messages. but increasing the number of buffers doesn't seem to
be the best fix for a 'silent freeze'.

It might be that the driver would be more robust if it only ever
put rx buffers into all but one of the ring slots.

	David
