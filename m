From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] iproute2: add support for tcp_metrics
Date: Wed, 3 Oct 2012 09:20:02 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B701A@saturn3.aculab.com>
References: <1349210716-25509-1-git-send-email-ja@ssi.bg><1349211876.12401.1101.camel@edumazet-glaptop><1349213229.12401.1130.camel@edumazet-glaptop><alpine.LFD.2.00.1210030302320.25856@ja.ssi.bg> <20121002172633.2be06886@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Julian Anastasov" <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41823 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752418Ab2JCI1t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 04:27:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03066-03 for <netdev@vger.kernel.org>;
 Wed,  3 Oct 2012 09:27:42 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20121002172633.2be06886@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > 	fprintf(fp, "%lluus",
> > 		((__u64) val * 1000) >> 2);
...
> Remember u64 is not always same as unsigned long long.
> One safe way of handling this is:
...
> 	fprintf(fp, "%"PRIu64"us",
>  		((__u64) val * 1000) >> 3);

Or convert the constant.
	fprintf(fp, "%lluus", (val * 1000ull) >> 2);
which may well generate better code on 32bit systems.

	David
