From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 16:55:14 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EA1@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E9E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>,
	"Maciej Zenczykowski" <zenczykowski@gmail.com>,
	"Maciej Zenczykowski" <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43684 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757666Ab2CMQ4P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 12:56:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04026-01 for <netdev@vger.kernel.org>;
 Tue, 13 Mar 2012 16:56:13 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E9E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > +	/* For i in 0..7 returns {-1, 0, 1, 0, 2, 0, 1, 0}[i] */
> > +	return ((26468 >> (i+i)) & 3) - 1;
> 
> That expression doesn't seem quite right to me ...
> 	return (int)(0x12131210 >> (i * 4)) & 3) - 1;
> probably does what is wanted.

Hmmm... I'm going blind - I read that as 'i+1' not 'i+i'.
But using 'i * 4' and putting the constant in base 16
make the code rather less obscure.

	David
