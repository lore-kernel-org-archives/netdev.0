From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3] Renesas Ethernet AVB driver
Date: Tue, 14 Apr 2015 11:31:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1DA25@AcuExch.aculab.com>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
 <552C63FD.9010005@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>
To: 'Lino Sanfilippo' <LinoSanfilippo@gmx.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:53161 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754970AbbDNLdD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 07:33:03 -0400
In-Reply-To: <552C63FD.9010005@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo
> On 14.04.2015 00:07, Sergei Shtylyov wrote:
> 
...
> > +#ifdef __LITTLE_ENDIAN
> > +	u32 res: 16;	/* Reserved bits */
> > +	u32 ts_sh: 16;	/* Timestamp high */
> > +#else
> > +	u32 ts_sh: 16;	/* Timestamp high */
> > +	u32 res: 16;	/* Reserved bits */
> > +#endif
> > +};
> 
> I recall a thread in which the use of bitfields for structs that are
> shared with the hardware was considered a bad idea (because the compiler
> is free to reorder the fields). Shift operations are probably a better
> choice here.

The compiler itself isn't free to reorder the fields, but the order
is an implementation decision for the compiler/ABI.
An ABI will probably define a bit order, but it doesn't have to match
the endianness.

Shifting and masking also tends to generate better code.

	David
