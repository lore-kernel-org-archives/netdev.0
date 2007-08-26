From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] Prefix each line of multiline printk(KERN_<level> "foo\nbar") with KERN_<level>
Date: Sun, 26 Aug 2007 06:54:10 -0400
Message-ID: <8bd0f97a0708260354xb4c8546od0cc19a590820f32@mail.gmail.com>
References: <1187999098.32738.179.camel@localhost>
	 <Pine.LNX.4.64.0708261028120.31149@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Joe Perches" <joe@perches.com>, linux-kernel@vger.kernel.org,
	blinux-list@redhat.com, cluster-devel@redhat.com,
	discuss@x86-64.org, jffs-dev@axis.com, linux-acpi@vger.kernel.org,
	linux-ide@vger.kernel.org, linux-mips@linux-mips.org,
	linux-mm@kvack.org, linux-mtd@lists.infradead.org,
	linux-scsi@vger.kernel.org, mpt_linux_developer@lsi.com,
	netdev@vger.kernel.org, osst-users@lists.sourceforge.net,
	parisc-linux@parisc-linux.org, tpmdd-devel@lists.sourceforge.net,
	uclinux-dist-devel@blackfin.uclinux.org
To: "Geert Uytterhoeven" <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:51452 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbXHZKyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2007 06:54:11 -0400
Received: by nz-out-0506.google.com with SMTP id s18so837595nze
        for <netdev@vger.kernel.org>; Sun, 26 Aug 2007 03:54:10 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0708261028120.31149@anakin>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/26/07, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Fri, 24 Aug 2007, Joe Perches wrote:
> > Corrected printk calls with multiple output lines which
> > did not correctly preface each line with KERN_<level>
> >
> > Fixed uses of some single lines with too many KERN_<level>
>
> > --- a/arch/arm/kernel/ecard.c
> > +++ b/arch/arm/kernel/ecard.c
> > @@ -547,7 +547,8 @@ static void ecard_check_lockup(struct irq_desc *desc)
> >       if (last == jiffies) {
> >               lockup += 1;
> >               if (lockup > 1000000) {
> > -                     printk(KERN_ERR "\nInterrupt lockup detected - "
> > +                     printk(KERN_ERR "\n"
> > +                            KERN_ERR "Interrupt lockup detected - "
> >                              "disabling all expansion card interrupts\n");
> >
> >                       desc->chip->mask(IRQ_EXPANSIONCARD);
>
> What's the purpose of having lines printed with e.g. `KERN_ERR "\n"' only?
> Shouldn't these just be removed?
>
> Usually lines starting with `\n' are continuations, but given some other
> module may call printk() in between, there's no guarantee continuations
> appear on the same line.

erm, i thought the prink lock was grabbed per-buffer, not per-line ...
so yes, if the function calls were like printk(KERN_ERR "\n");
printk(KERN_ERR "..."); things could be broken up, but this is on
function call, so it shouldnt ...
-mike
