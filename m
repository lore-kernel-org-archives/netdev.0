From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: Re: [PATCH] rtnl_wilddump_request: fix alignment issue for
 embedded platforms
Date: Thu, 30 Aug 2012 18:09:48 +0200
Message-ID: <20120830160948.GA26387@lutz.bln.innominate.local>
References: <1345621133-23583-1-git-send-email-ljaenicke@innominate.com>
 <1346338894-12600-1-git-send-email-ljaenicke@innominate.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6FC9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.bln.innominate.com ([77.245.32.75]:54049 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab2H3QJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:09:50 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC9@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 30, 2012 at 04:51:49PM +0100, David Laight wrote:
> > +		/* attribute has to be NLMSG aligned */
> > +		struct rtattr ext_req
> __attribute__((aligned(NLMSG_ALIGNTO)));
>=20
> Would it be better to apply the attribute to the definition
> of 'struct rtattr' itself ?

'struct rtattr' is defined in a kernel header and I am not really sure
what kind of side effects it would have.

The problem I intend to solve with my page is rather caused by the use =
case:
The request is sent as a single structure, the processing is however
performed step by step: first the nlmsg is parsed, then the pointer
is moved on to the parsing of the content. This pointer is hoever not
oriented at the structure element but by using size information which
is then adjust by NLMSG_ALIGN() etc. Consequently one should actually
use the same method in sending (generate the header first, then addattr=
_()
which enforces protocol conform alignment). This is the way all other
instances in iproute2 generate their messages btw.

I hence consider my proposed patch to be the least intrusive solution.

Best regards,
	Lutz
--=20
Dr.-Ing. Lutz J=E4nicke
CTO
Innominate Security Technologies AG  /protecting industrial networks/
tel: +49.30.921028-200
fax: +49.30.921028-020
Rudower Chaussee 13
D-12489 Berlin, Germany
www.innominate.com

Register Court: AG Charlottenburg, HR B 81603
Management Board: Dirk Seewald
Chairman of the Supervisory Board: Christoph Leifer
