From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 17:11:11 +0100
Message-ID: <64bb37e0712310811r34423ff5q2e9516d02f6247de@mail.gmail.com>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
	 <20071231144255.GB13803@does.not.exist>
	 <64bb37e0712310755k2446e67eq81d31cd476eb75e3@mail.gmail.com>
	 <200712311659.14847.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@kernel.org>, "Bodo Eggert" <7eggert@gmx.de>,
	"Jan Engelhardt" <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:13265 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbXLaQLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 11:11:12 -0500
Received: by py-out-1112.google.com with SMTP id u52so9082368pyb.10
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 08:11:11 -0800 (PST)
In-Reply-To: <200712311659.14847.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 31, 2007 4:59 PM, Michael Buesch <mb@bu3sch.de> wrote:
> On Monday 31 December 2007 16:55:57 Torsten Kaiser wrote:
> > One thing I always wondered about in this discussion about wasted
> > EXPORT_SYMBOL's:
> > Shouldn't it be possible to garbage collect these?
> >
> > depmod already contains code to analyze all modules to create a
> > dependency tree. It should not be too difficult to extend it to create
> > a list of all symbols that really are used by the current modules.
> > Everything else could be stripped to save space.
> >
> > The problem with that:
> > * out-of-tree modules would break if they don't get lucky to only use
> > the remaining symbol. I would not see this as a problem, if the help
> > text of the garbage-collect-option would contain a note like "don't
> > enable this if you want out-of-tree modules".
> > * if you later change your .config to include additional modules you
> > might need to rebuild vmlinux and reboot into the new kernel.
> > Currently you can probably build and load new modules without a
> > reboot. (for example: usb drivers)
>
> I'd say the practical advantage to the user would be almost zero.
> Which distribution is going to enable this option and defacto
> banning external modules?

I would default this option to not remove used symbols, because it
could break something.
For distributions it could be used in both ways:
* enabled -> only "distro approved" modules can be loaded
* disabled -> works as of now

For every other user who compiles own kernels without external modules
(Not including out-of-tree drivers that get patched into the kernel
code! Only modules that get compiled later independent from the kernel
build!) it will save space.

If this space would not matter there would be no need to be so hard on
currently unused EXPORT_SYMBOLs.

Torsten
