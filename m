From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 11:42:36 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B702D@saturn3.aculab.com>
References: <20121010093816.GA3669@elgon.mountain> <1349864358.2386.27.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Karsten Keil" <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Masanari Iida" <standby24x7@gmail.com>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52018 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752509Ab2JJKug convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 06:50:36 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27317-09 for <netdev@vger.kernel.org>;
 Wed, 10 Oct 2012 11:50:32 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1349864358.2386.27.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -		unsigned long protos[8] = {0,};
> +		DECLARE_BITMAP(protos, BITS_PER_LONG * 8) = { 0, };
...
> -		if ((r = set_arg(argp, protos, 8 * sizeof(long))))
> +		if ((r = set_arg(argp, protos, sizeof(protos))))

That change makes a big assumption about the implementation
of DECLARE_BITMAP().
Unless it is guaranteed to be implemented as 'unsigned long[]'
then you've changed what the code might do.

	David
