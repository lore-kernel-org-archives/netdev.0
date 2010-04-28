From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Wed, 28 Apr 2010 08:08:37 +0200
Message-ID: <20100428060837.GB4516@riccoc20.at.omicron.at>
References: <20100427091405.GA5098@riccoc20.at.omicron.at> <20100427153239.0977c1aa.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:49009 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832Ab0D1GIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 02:08:43 -0400
Received: by fg-out-1718.google.com with SMTP id 19so3094135fgg.1
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 23:08:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100427153239.0977c1aa.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 03:32:39PM -0700, Randy Dunlap wrote:
> How do I use the testptp.mk file?

The makefile uses the KBUILD_OUTPUT environment variable to find the
kernel includes, with the new header. I do something like this:

  export ARCH=powerpc
  export KBUILD_OUTPUT=~/work/kernel/ptp_p2020
  mkdir -p $KBUILD_OUTPUT
  make mpc85xx_smp_defconfig
  make menuconfig
  make -j3 uImage
  make headers_install
  make -C Documentation/ptp -f testptp.mk

> Drop the ".ko".  We normally don't include that part of the module name.

Okay, can do. I just imitated what I saw in other Kbuild files.

> > diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> > index 2fc8e14..2d616cb 100644
> > --- a/include/linux/Kbuild
> > +++ b/include/linux/Kbuild
> > @@ -318,6 +318,7 @@ unifdef-y += poll.h
> >  unifdef-y += ppp_defs.h
> >  unifdef-y += ppp-comp.h
> >  unifdef-y += pps.h
> > +unifdef-y += ptp_clock.h
> >  unifdef-y += ptrace.h
> >  unifdef-y += quota.h
> >  unifdef-y += random.h
> 
> I think that the Kbuild file also needs this line:
> header-y += ptp_clock.h
> 
> so that builds that use O=objdir will work, but even with that
> change, I couldn't get it to work.  (?)

Well, I am not sure what to do here. I followed the example of the PPS
code. That code only has the unifdef-y assigment. But now I see that
Documentation/kbuild/makefiles.txt says unifdef-y is deprecated.

Can someone clarify what is correct: is just header-y enough?

Thanks,
Richard
