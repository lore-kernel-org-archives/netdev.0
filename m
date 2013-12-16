From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 2/3] packet: fill the gap of TPACKET_ALIGNMENT with zeros
Date: Mon, 16 Dec 2013 10:16:48 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7491@saturn3.aculab.com>
References: <87ob4h6wq1.wl%atzm@stratosphere.co.jp> <52AED170.9020604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>
To: "Daniel Borkmann" <dborkman@redhat.com>,
	"Atzm Watanabe" <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51189 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752054Ab3LPKSJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:18:09 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09963-10 for <netdev@vger.kernel.org>;
 Mon, 16 Dec 2013 10:18:06 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52AED170.9020604@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +		memset(h.h2->tp_padding, 0,
> > +		       hdrlen - offsetof(struct tpacket2_hdr, tp_padding));

What is wrong with 'sizeof h.h2->tp_padding' ?
The compiler will probably inline the memset into a couple of word
sized writes of zero - probably not measurable.
Not zeroing them might be leaking kernel memory contents (depends
where the memory came from - might just be stale packet data).

	David
