From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: bpf pointer alignment validation
Date: Wed, 10 May 2017 11:12:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE86D8@AcuExch.aculab.com>
References: <20170505.162044.2097924822206705957.davem@davemloft.net>
 <20170505.224709.1156323937148435706.davem@davemloft.net>
 <59104D35.8080108@iogearbox.net>
 <20170509.143234.1785658771452710730.davem@davemloft.net>
 <20170510055735.hfkoh4w3xaka5yl5@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@fb.com" <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:64800 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdEJLMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 07:12:18 -0400
In-Reply-To: <20170510055735.hfkoh4w3xaka5yl5@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov
> Sent: 10 May 2017 06:58
> > +static u32 calc_align(u32 imm)
> > +{
> > +	u32 align = 1;
> > +
> > +	if (!imm)
> > +		return 1U << 31;
> > +
> > +	while (!(imm & 1)) {
> > +		imm >>= 1;
> > +		align <<= 1;
> > +	}
> > +	return align;
> > +}
> 
> same question as in previous reply.
> Why not to use something like:
> static u32 calc_align(u32 n)
> {
>         if (!n)
>                 return 1U << 31;
>         return n - ((n - 1) & n);
> }

That function needs a comment saying what it returns.
Think I'd write it as:
		return n & ~(n & (n - 1));
(even though that might be one more instruction)

	David
