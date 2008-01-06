From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 6 Jan 2008 12:35:35 +0100
Message-ID: <64bb37e0801060335k4afb3134u9c6fadb57d525dc5@mail.gmail.com>
References: <20080105172524.fecb63bf.akpm@linux-foundation.org>
	 <20080106123103K.tomof@acm.org>
	 <64bb37e0801060241o2c6d8172r73b69291fce76ce1@mail.gmail.com>
	 <20080106202616Z.tomof@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com, fujita.tomonori@lab.ntt.co.jp
To: "FUJITA Tomonori" <tomof@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:5927 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbYAFLfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 06:35:37 -0500
Received: by py-out-1112.google.com with SMTP id u52so11969952pyb.10
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2008 03:35:36 -0800 (PST)
In-Reply-To: <20080106202616Z.tomof@acm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 6, 2008 12:23 PM, FUJITA Tomonori <tomof@acm.org> wrote:
> On Sun, 6 Jan 2008 11:41:10 +0100
> "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> > I will applie your patch and see if this hunk from
> > find_next_zero_area() makes a difference:
> >
> >        end = index + nr;
> > -       if (end > size)
> > +       if (end >= size)
> >                 return -1;
> > -       for (i = index + 1; i < end; i++) {
> > +       for (i = index; i < end; i++) {
> >                 if (test_bit(i, map)) {
>
> The patch should not make a difference for X86_64.

Hmm...
arch/x86/kernel/pci-gart_64.c:
alloc_iommu() calls iommu_area_alloc()
lib/iommu-helper.c:
iommu_area_alloc() calls find_next_zero_area()
-> so the above code should be called even on X86_64

And the change in the for loop means that 'index' will now be tested,
but with the old code it was not.

And double using something does fit with the errors I'm seeing...

> Can you try the patch to revert my IOMMU changes?
>
> http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg12694.html

Testing for this bug is a little bit slow, as I'm compiling ~100
packages trying to trigger it.
If my current testrun with the patch from
http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg12702.html
crashes, I will revert the hole IOMMU changes with above patch and try again.

Torsten
