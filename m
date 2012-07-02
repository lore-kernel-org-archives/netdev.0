From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules with ethtool
Date: Mon, 2 Jul 2012 13:15:12 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F71@saturn3.aculab.com>
References: <m28vf2o0oa.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Joe Perches" <joe@perches.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, "Hadar Hen Zion" <hadarh@mellanox.co.il>
To: "Andreas Schwab" <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42292 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750878Ab2GBMSs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 08:18:48 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03910-04 for <netdev@vger.kernel.org>;
 Mon,  2 Jul 2012 13:18:41 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <m28vf2o0oa.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> "David Laight" <David.Laight@ACULAB.COM> writes:
> 
> >  
> >> > Or write it as (!field || !(typeof(field))~field) which more
closely
> >> > resembles what the macro name expresses.
> >> 
> >> Better still, or maybe:
> >> 
> >> 	field == 0 || field == (typeof field)~0
> >
> > Which doesn't work when sizeof(field) > sizeof(int).
> > Needs another cast.
> >
> > 	field == 0 || field == (typeof field)~(typeof field)0
> 
> You can avoid that by using (typeof field)-1.

Gah, I thought I knew the integral promotion rules!
-1 and ~0 are both 'integer' and get treated the same.

A quick test shows that gcc does sign extend when converting
32bit int to 64bit unsigned long long.
Which probably means that is required by the standard!

	David
