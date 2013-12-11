From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] packet: Deliver VLAN TPID to userspace
Date: Wed, 11 Dec 2013 13:19:21 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7480@saturn3.aculab.com>
References: <8738m0q3nq.wl%atzm@stratosphere.co.jp>	<AE90C24D6B3A694183C094C60CF0A2F6026B7476@saturn3.aculab.com> <87txef7dmy.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>,
	"Daniel Borkmann" <dborkman@redhat.com>
To: "Atzm Watanabe" <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57614 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751345Ab3LKNU0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 08:20:26 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09348-05 for <netdev@vger.kernel.org>;
 Wed, 11 Dec 2013 13:20:21 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <87txef7dmy.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Atzm Watanabe
...
> > You've defined a new header variant, but all the code seems to rely
> > on the fact that the 'new' variant is identical to the old one
> > with the addition of an extra field at the end.
> >
> > In which case it ought to be valid to just extend the old header variant.
> > If the header really can change format there ought to be a discriminating
> > member somewhere - which you don't seem to have changed.
> 
> Yes.  I think that struct tpacket3_hdr can grow safely until 48 bytes,
> so I'd just like to extend tpacket_hdr_variant1 like you said.
> 
> But in the past discussions, there were mentions that a new member
> cannot be added into struct tpacket_hdr_variant1, and possibly the
> variant which includes a new member should be separated from the old
> one.
> 
>   http://patchwork.ozlabs.org/patch/284671/
>   http://patchwork.ozlabs.org/patch/285382/

I don't remember it being mentioned earlier that there are pad bytes
following the header.

Might be worth explicitly defining the pad bytes and zeroing them.
That could make additional changes easier.

	David
