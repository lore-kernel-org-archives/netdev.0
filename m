From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute-3.8.0 build error on Linux ppc64
Date: Wed, 27 Feb 2013 07:28:30 -0800
Message-ID: <20130227072830.6ab4373e@nehalam.linuxnetplumber.net>
References: <CABMX=WwSNeTq_ascBRxJtQrsErR-cFODZQh_wrim6K8weyLDtQ@mail.gmail.com>
	<CABMX=WxaxNhvx4YA6-KiDjoRURXsotCSEpxQJu4mK11UtW78jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nello martuscielli <ppc.addon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:44331 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760001Ab3B0P26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 10:28:58 -0500
Received: by mail-da0-f52.google.com with SMTP id x33so345391dad.39
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 07:28:58 -0800 (PST)
In-Reply-To: <CABMX=WxaxNhvx4YA6-KiDjoRURXsotCSEpxQJu4mK11UtW78jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Feb 2013 06:37:46 +0100
nello martuscielli <ppc.addon@gmail.com> wrote:

> sorry, it was your previous commit about -Werror
> 
> thanks,
> Nell
> 
> 
> 
> On Wed, Feb 27, 2013 at 6:08 AM, nello martuscielli <ppc.addon@gmail.com> wrote:
> > hi,
> > after your commit:
> > http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=commitdiff;h=6398d3a65277a2ebed085ad9deef15fea6f4ed09
> >
> > specifically -Wmissing-prototypes and I get this error on Linux ppc64
> >
> > gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
> > -Wmissing-declarations -Wold-style-definition -O2 -I../include
> > -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\"
> > -D_GNU_SOURCE   -c -o ipntable.o ipntable.c
> > cc1: warnings being treated as errors
> > ipntable.c: In function 'print_ntable':
> > ipntable.c:435:3: error: format '%llu' expects type 'long long

Pushed up a fix for this using casts.
Would rather have used inttypes.h but that was incompatible with kernel's __u64.
