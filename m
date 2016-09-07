From: Albert ARIBAUD <albert.aribaud@3adev.fr>
Subject: Re: [Y2038] Fourth draft of the Y2038 design document
Date: Wed, 7 Sep 2016 12:05:22 +0200
Message-ID: <20160907120522.7359185e.albert.aribaud@3adev.fr>
References: <20160622005838.60a95c44.albert.aribaud@3adev.fr>
        <CABeXuvr0cAgP4hqRnskV8+oTozEtLz9dNO-9_Lw6-r3XnThVFQ@mail.gmail.com>
        <CABeXuvqTyXmFL_-2HiB6BZnj=EfXc5bNLB=sQ36m8-ouyWH0Zw@mail.gmail.com>
        <6410260.Js2exyRRNi@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: y2038@lists.linaro.org, Deepa Dinamani <deepa.kernel@gmail.com>,
        libc-alpha@sourceware.org, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:36051 "EHLO
        smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752318AbcIGKFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 06:05:45 -0400
Received: from smtp3-g21.free.fr (smtp3-g21.free.fr [212.27.42.3])
        by smtpfb2-g21.free.fr (Postfix) with ESMTP id 350BBCAC407
        for <netdev@vger.kernel.org>; Wed,  7 Sep 2016 12:05:41 +0200 (CEST)
In-Reply-To: <6410260.Js2exyRRNi@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On Thu, 14 Jul 2016 13:39:13 +0200, Arnd Bergmann <arnd@arndb.de>
wrote :

> On Wednesday, July 13, 2016 7:38:25 PM CEST Deepa Dinamani wrote:
> > On Wed, Jul 13, 2016 at 1:40 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:  
> 
>  [...]  
>  [...]  
> > >
> > > Another way of handling this would be to use the flags in sendmsg/recvmsg.
> > > Since cmsg is sent using these calls, at the time of call, sendmsg/recvmsg can
> > > indicate whether 64 bit time_t or 32 bit time_t is used.
> > > This will eliminate the need for new options and kernel need not depend on
> > > __USE_TIME_BITS64.  
> 
> Good point, I had forgotten how we discussed that a while ago.
> 
>  [...]  
>  [...]  
> > >
> > > But, if we are not using optlen here, then probably just using new numbers for
> > > timestamps also makes sense.  
> > 
> > Forgot to note one more thing here.
> > Since we are already using struct sizes for ioctls, shouldn't this be similar.
> > So optlen should also be okay?
> > Just as in the example Arnd pointed out above:
> > 
> > /* Set and get port timeout (struct timeval's) */
> > #define PPGETTIME       _IOR(PP_IOCTL, 0x95, struct timeval)
> > #define PPSETTIME       _IOW(PP_IOCTL, 0x96, struct timeval)  
> 
> I've added the netdev list and David Miller to Cc here, it seems
> either way would work, and I don't have a strong preference.
> 
> a) add a flag to recvmsg() that glibc always passes when called
>    using __USE_TIME_BITS64 to handle reading the timestamps, and
>    rely on the optlen value for SO_RCVTIMEO/SO_SNTTIMEO to
>    decide how to interpret the data
> 
> b) handle all five sockopts using conditional option numbers
>    and don't rely on the recvmsg() flag or optlen.
> 
> Using either a) or b) is probably better than a combination of
> them, so I've not listed that as another alternative.
> 
> To work around the header inclusion order problem we discussed
> earlier for approach b), I suppose we can do this using
> something like
> 
> 
> #define SO_RCVTIMEO_TIME32	21
> #define SO_RCVTIMEO_TIME64	53
> 
> #define SO_RCVTIMEO (__USE_TIME_BITS==64 ? SO_RCVTIMEO_TIME64 : SO_RCVTIMEO_TIME32)
> 
> where __USE_TIME_BITS is a macro defined by the libc. We cannot easily
> check for whether a macro is defined in a conditional expression,
> but I think the above should work, as long as we don't need use the
> value from assembler code.
> 
> 	Arnd

Seems like there was no reply on the netdev or libc-alpha lists or from
David. I personally am not fond of relying on length to determine which
variant of an argument we are dealing with, therefore I prefer option b
over option a and will update the design doc accordingly.

Cordialement,
Albert ARIBAUD
3ADEV
