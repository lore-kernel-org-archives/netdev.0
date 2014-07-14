From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 1/3] net: sctp: Open out the check for Nagle
Date: Mon, 14 Jul 2014 09:12:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D172719BD@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1726EEB9@AcuExch.aculab.com>
 <53C04280.8020809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43121 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753936AbaGNJNX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 05:13:23 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13516-05 for <netdev@vger.kernel.org>;
 Mon, 14 Jul 2014 10:13:14 +0100 (BST)
In-Reply-To: <53C04280.8020809@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
...
> > +	if (inflight != 0)
> > +		/* Nothing unacked */
> > +		return SCTP_XMIT_OK;
> 
> This doesn't look right.  First, the comment doesn't match the condition.
> Second, when we have stuff in-flight we might be affected be Nagle.  Thus,
> I think the condition should be:
>        if (!inflight)
> 
> Then the commend and logic holds.

Gah, I accidentally inverted the condition :-(
I changed it to a an explicit comparison because 'inflight' is actually
the number of bytes that are unacked.

I'll repost the series later in the week.

	David
