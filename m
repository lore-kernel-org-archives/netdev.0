From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: [PATCHv3 5/5] [NET] dsa: add support for the Marvell 88E6060 switch chip
Date: Wed, 8 Oct 2008 15:20:18 -0500
Message-ID: <2acbd3e40810081320oe022835r7e6f53abc1147542@mail.gmail.com>
References: <20081007234622.GF23200@xi.wantstofly.org>
	 <Pine.LNX.4.64.0810071725300.4731@k.domain.actdsltmp>
	 <20081008084903.GE23326@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Trent Piepho" <tpiepho@freescale.com>, netdev@vger.kernel.org
To: "Lennert Buytenhek" <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:34935 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbYJHUUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 16:20:20 -0400
Received: by gxk9 with SMTP id 9so8783687gxk.13
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 13:20:18 -0700 (PDT)
In-Reply-To: <20081008084903.GE23326@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 8, 2008 at 3:49 AM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Tue, Oct 07, 2008 at 05:45:41PM -0700, Trent Piepho wrote:
>

>> > +#define REG_READ(addr, reg)                                        \
>> > +   ({                                                      \
>> > +           int __ret;                                      \
>> > +                                                           \
>> > +           __ret = reg_read(ds, addr, reg);                \
>> > +           if (__ret < 0)                                  \
>> > +                   return __ret;                           \
>> > +           __ret;                                          \
>> > +   })
>>
>> Macro with a hidden use of a local ('ds') and a hidden return?  The
>> former is discouraged (but can sure save a lot of typing) but the
>> latter seems like it's just begging to cause a missing unlock or
>> free on an error path.
>
> Yeah, well, that was intentional (Nicolas Pitre suggested it, and I
> figured it made sense to do it).  I think there are a couple more places
> in the tree that do this, and it very much increases readability because
> you no longer need to check the return value explicitly every single
> time you do an MII access.

I agree with Trent, it only increases readability in the sense that
you have to read less when scanning over the code.  To me, that is the
least important sort of readability.  This sort of macro just creates
hidden traps.  I know it's annoying to check that return value every
time, but that's why we get paid the big bucks.  ;)

If, for some reason, the community feels this is the right way to go,
at *least* rename the macro to make it clear that it returns on an
error, and make ds an explicit parameter.

Andy
