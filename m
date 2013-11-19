From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] neigh: Force garbage collection if an entry is deleted administratively
Date: Tue, 19 Nov 2013 12:08:06 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7432@saturn3.aculab.com>
References: <20131112085714.GU31491@secunet.com> <20131114.022356.1095983243221745109.davem@davemloft.net> <20131118100843.GY31491@secunet.com> <20131118.162115.407611651189468804.davem@davemloft.net> <20131119115414.GZ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>
To: "Steffen Klassert" <steffen.klassert@secunet.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44359 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752011Ab3KSMIy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 07:08:54 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14059-10 for <netdev@vger.kernel.org>;
 Tue, 19 Nov 2013 12:08:50 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131119115414.GZ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > My conclusion is that the management of the state is the problem.
> > Specifically, if we invalidate an entry then we should remove it's
> > visisbility.  This means the table should operate by unhashing the
> > entry unconditionally during such operations.
> >
> > If some stray references exist, that's fine, the entity holding the
> > reference will perform the final neigh cleanup at release time.
> >
> > Does this make sense to you?
> 
> Yes, makes sense :-)

Isn't it enough to act as if the entry were not in the hash tables.
So an attempt to add such an entry wouldn't fail.

I've not looked at these code paths, but it can easily be that when
the entry is invalidated the hash table isn't (and can't easily be)
locked - just having the entry locked may make it difficult.

Whereas the code path to add an entry can easily delete old entries.

	David
