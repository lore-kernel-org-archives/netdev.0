From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/4] net/mlx4_en: Use atomic counter to decide when queue is full
Date: Mon, 25 Jun 2012 10:00:03 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F61@saturn3.aculab.com>
References: <20120622.172353.1092394608024377078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37933 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751275Ab2FYJBV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 05:01:21 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16004-05 for <netdev@vger.kernel.org>;
 Mon, 25 Jun 2012 10:01:19 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120622.172353.1092394608024377078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > The Transmit and transmit completion flows execute from different
contexts,
> > which are not synchronized. Hence naive reading the of consumer
index might
> > give wrong value by the time it is being used, That could lead to a
state of transmit timeout.
> > Fix that by using atomic variable to maintain that index.
> > 
> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> I'm not convinced.  There is only one place that actually changes
> the counter.
> 
> So it seems more like you have a missing memory barrier somewhere.

Or just keep the two ring indexes - instead of keeping the
number of 'active' entries as well.
Then you don't have a variable which the tx setup and
tx completion routines both update.

	David
