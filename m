From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/9] net: phy: dp83640: fix checkpath error
Date: Fri, 20 Dec 2013 09:46:59 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B74BD@saturn3.aculab.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com> <1387345093-14168-4-git-send-email-f.fainelli@gmail.com> <1387492262.2353.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>,
	"Florian Fainelli" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43785 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754734Ab3LTJsf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 04:48:35 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27957-09 for <netdev@vger.kernel.org>;
 Fri, 20 Dec 2013 09:48:32 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1387492262.2353.26.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Joe Perches
> Sent: 19 December 2013 22:31
> On Tue, 2013-12-17 at 21:38 -0800, Florian Fainelli wrote:
> > diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
> []
> > @@ -851,8 +851,8 @@ static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
> >
> >  	seqid = (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
> >
> > -	return (rxts->msgtype == (*msgtype & 0xf) &&
> > -		rxts->seqid   == ntohs(*seqid));
> > +	return rxts->msgtype == (*msgtype & 0xf) &&
> > +		rxts->seqid   == ntohs(*seqid);
> 
> I think this isn't an improvement.
> 
> Maybe:
> 	return rxts->msgtype == (*msgtype & 0xf) &&
> 	       rxts->seqid == ntohs(*seqid);
> or
> 	return (rxts->msgtype == (*msgtype & 0xf)) &&
> 	       (rxts->seqid == ntohs(*seqid));

Or even (modulo stupid errors):
	return !((rxts->msgtype ^ (*msgtype & 0xf))
		  | (rxts->seqid ^ ntohs(*seqid)));
which saves a branch if the conditional is usually true.

	David
