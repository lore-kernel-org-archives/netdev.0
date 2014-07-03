From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Thu, 3 Jul 2014 17:57:38 +0100
Message-ID: <CACxGe6ufcUtu7NioLdNSLmy8nWHr_E4FpQrmyhPrH0Qee+13SA@mail.gmail.com>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
 <20140702.182807.1245632778216212860.davem@davemloft.net> <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
 <1404356734.14741.18.camel@joe-AO725> <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
 <1404364565.14741.26.camel@joe-AO725> <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
 <1404368746.14741.36.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:60332 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758506AbaGCQ57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 12:57:59 -0400
Received: by mail-ie0-f179.google.com with SMTP id tr6so486814ieb.10
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 09:57:58 -0700 (PDT)
In-Reply-To: <1404368746.14741.36.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 3, 2014 at 7:25 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2014-07-03 at 07:01 +0100, Maciej W. Rozycki wrote:
>> On Wed, 2 Jul 2014, Joe Perches wrote:
>>
>> > > > The kernel vsprintf implementation doesn't prefix
>> > > > pointers with 0x, so you can use 0x%p if you really
>> > > > want that with a leading prefix, but you don't have
>> > > > to use it.
>> > >
>> > >  It does, when the `#' format modifier is used (go try yourself!).
>> >
>> > I know it does, but it's incidental.
>>
>>  Is it?  Someone took the effort to handle it:
>>
>>       int default_width = 2 * sizeof(void *) + (spec.flags & SPECIAL ? 2 : 0);
>>
>> while they could do:
>>
>>       int default_width = 2 * sizeof(void *);
>>
>>       spec.flags &= ~SPECIAL;
>
> Grant Likely did that a couple of years ago.
>
> commit 725fe002d315c2501c110b7245d3eb4f4535f4d6
> Author: Grant Likely <grant.likely@secretlab.ca>
> Date:   Thu May 31 16:26:08 2012 -0700
>
>     vsprintf: correctly handle width when '#' flag used in %#p format
>
>     The '%p' output of the kernel's vsprintf() uses spec.field_width to
>     determine how many digits to output based on 2 * sizeof(void*) so that all
>     digits of a pointer are shown.  ie.  a pointer will be output as
>     "001A2B3C" instead of "1A2B3C".  However, if the '#' flag is used in the
>     format (%#p), then the code doesn't take into account the width of the
>     '0x' prefix and will end up outputing "0x1A2B3C" instead of "0x001A2B3C".
>
>     This patch reworks the "pointer()" format hook to include 2 characters for
>     the '0x' prefix if the '#' flag is included.
>
> Not sure it ever mattered myself.

I had code using it. It was long enough ago that I'd don't remember
exactly why. Apparently it never made it into the kernel or it got
reverted by someone else.

g.
