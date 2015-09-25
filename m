From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [RFC v2 net-next 05/10] qede: Add basic network device support
Date: Fri, 25 Sep 2015 05:43:06 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E32A5E@avmb3.qlogic.org>
References: <1442499839-22762-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1442499839-22762-6-git-send-email-Yuval.Mintz@qlogic.com>
 <20150924142536.052d6175@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:25432 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754439AbbIYFnJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 01:43:09 -0400
In-Reply-To: <20150924142536.052d6175@urahara>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > +#define QEDE_NAPI_WEIGHT	(NAPI_POLL_WEIGHT)
> > Why not just use existing constant rather than walpapering?

No reason; We'll remove it.

> > > +#define U64_LO(x)			((u32)(((u64)(x)) & 0xffffffff))
> > > +#define U64_HI(x)			((u32)(((u64)(x)) >> 32))
> > > +#define HILO_U64(hi, lo)		((((u64)(hi)) << 32) + (lo))
> > 
> > Why reinvent upper32 and lower32?

Ignorance? And I assume you meant {upper, lower}_32_bits.
Is there also a standard macro doing what HILO_U64 does?

> > +struct qede_rx_queue {
> > +	__le16			*hw_cons_ptr;
> 
> The __ variants of constants should be reserved for use in user visible API's

Really? If so, this needs to be fixed not only here but in lots of places
in the series [e.g., entire HW HSI uses __le variants instead of le].
But why is it so? I.e., I understand that __le16 is defined in the uapi directory and
thus accessible to users, but why the distinction?
[I'm looking at bnx2x_hsi.h for reference which is full with the __le variants;
Not saying that's a good thing, though]

> > > +	int			rx_buf_size;
> > 
> > Shouldn't rx_buf_size be unsigned?

Yes.
