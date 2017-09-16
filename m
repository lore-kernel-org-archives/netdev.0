From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH V2] tipc: Use bsearch library function
Date: Sat, 16 Sep 2017 13:20:28 +0000
Message-ID: <DB5PR0701MB1958558286B3B455C601754A9A6D0@DB5PR0701MB1958.eurprd07.prod.outlook.com>
References: <20170911.143025.555018840006192902.davem@davemloft.net>
         <20170916075036.28676-1-thomas@m3y3r.de>
         <16128f5e-66ff-b6ec-c0e1-74ea08c212b0@windriver.com>
         <1505553970.16316.1.camel@perches.com>
         <64ee51ce-eb7e-ac1c-56a9-9481f6f80b35@windriver.com>
         <1505555908.16316.5.camel@perches.com>
         <35f41984-22e9-5adc-0e4d-a4ef4204f6d7@windriver.com>
 <1505557061.16316.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe@perches.com>, Ying Xue <ying.xue@windriver.com>,
        "Thomas Meyer" <thomas@m3y3r.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:64316 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdIPNUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 09:20:33 -0400
In-Reply-To: <1505557061.16316.7.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Joe Perches
> Sent: Saturday, September 16, 2017 06:18
> To: Ying Xue <ying.xue@windriver.com>; Thomas Meyer
> <thomas@m3y3r.de>; Jon Maloy <jon.maloy@ericsson.com>;
> netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net; linux-
> kernel@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH V2] tipc: Use bsearch library function
>=20
> On Sat, 2017-09-16 at 18:10 +0800, Ying Xue wrote:
> > On 09/16/2017 05:58 PM, Joe Perches wrote:
> > > On Sat, 2017-09-16 at 17:36 +0800, Ying Xue wrote:
> > > > On 09/16/2017 05:26 PM, Joe Perches wrote:
> > > > > On Sat, 2017-09-16 at 17:02 +0800, Ying Xue wrote:
> > > > > > On 09/16/2017 03:50 PM, Thomas Meyer wrote:
> > > > > > > Use common library function rather than explicitly coding
> > > > > > > some variant of it yourself.
> > > > > > >
> > > > > > > Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> > > > > >
> > > > > > Acked-by: Ying Xue <ying.xue@windriver.com>
> > > > >
> > > > > Are you sure you want to do this?
> > > > >
> > > > > Note the comment above nameseq_find_subseq
> > > > >
> > > > >  * Very time-critical, so binary searches through sub-sequence ar=
ray.
> > > > >
> > > > > What impact does this change have on performance?
> > > >
> > > > Sorry, I couldn't see any essential difference between this new
> > > > implementation and the original one except that the former tries
> > > > to use the library function - bsearch() to replace the original
> > > > binary search algorithm implemented in TIPC itself. Therefore, I
> > > > don't think the change will have a big impact on performance.
> > > >
> > > > If I miss something, please let me know.
> > >
> > > Comparison via a function pointer in bsearch is slower than direct
> > > code without the function call overhead.
> > >
> >
> > Right, but probably we can tolerate the slight sacrifice here.
>=20
> What part of "very time critical" have you verified and benchmarked as
> inconsequential?
>=20
> Please post your results.

I agree with Joe here. This change does not simplify anything, it does not =
reduce the amount of code, plus that it introduce an unnecessary outline ca=
ll in a place where we have every reason to let the compiler do its optimiz=
ation job properly.

///jon
