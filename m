From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 22:28:46 +0100
Message-ID: <472F8B0E.40408@o2.pl>
References: <1193939701.2987.82.camel@localhost.localdomain>	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>	 <20071105091231.GA1933@ff.dom.local>	 <1194267561.2987.141.camel@localhost.localdomain>	 <20071105135246.GB1933@ff.dom.local>  <1194271589.4438.113.camel@localhost> <1194283888.2987.186.camel@localhost.localdomain> <472F85F0.8060205@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:33922 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754036AbXKEVRe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 16:17:34 -0500
In-Reply-To: <472F85F0.8060205@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote, On 11/05/2007 10:06 PM:

> Radu Rendec wrote, On 11/05/2007 06:31 PM:

...

>> Jarek, because I have to test anyway, I'll include ffs(mask) in my patch
>> and have it tested too.
> 
> 
> Thanks! But, I did it wrong: + 1 is unnecessary. And since, ffs() checks
> for 0 anyway, this should be simpler:
> 
> - {
> - 	u8 i = 0;
> - 	u32 mask = s->hmask;
> - 	if (mask) {
> - 		while (!(mask & 1)) {
> - 			i++;
> - 			mask>>=1;
> - 		}
> - 	}
> - 	n->fshift = i;
> + 	n->fshift = ffs(s->hmask);
> - }
> 
> Plus maybe (u8) cast on warnings...
> 
> On the other hand, only now I see here is some hack (or bug) with this
> u8, so ffs() would mean a change here. I definitely need to rethink this.

> So, it's probably better to make and test this ffs() patch separately
> (2 parts).


Sorry, I'm only sleeping... u8 is fine of course, and it could be 1 part
as well, or as you like!

Jarek P.
