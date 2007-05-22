From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: select(0, ..) is valid ?
Date: Mon, 21 May 2007 18:21:18 -0700
Message-ID: <29495f1d0705211821r4200a1fft2b5c07a62b0620b1@mail.gmail.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
	 <Pine.LNX.4.64.0705151927360.28895@blonde.wat.veritas.com>
	 <20070516153703.GA26912@kryten> <200705181521.34339.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Anton Blanchard" <anton@samba.org>,
	"Hugh Dickins" <hugh@veritas.com>,
	"Christoph Lameter" <clameter@sgi.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Badari Pulavarty" <pbadari@us.ibm.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, sfr@canb.auug.org.au
To: "Andi Kleen" <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:31280 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756187AbXEVBVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 21:21:19 -0400
Received: by ug-out-1314.google.com with SMTP id 44so111085uga
        for <netdev@vger.kernel.org>; Mon, 21 May 2007 18:21:18 -0700 (PDT)
In-Reply-To: <200705181521.34339.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/18/07, Andi Kleen <ak@suse.de> wrote:
> On Wednesday 16 May 2007 17:37, Anton Blanchard wrote:
> > Hi Hugh,
> >
> > > It's interesting that compat_core_sys_select() shows this kmalloc(0)
> > > failure but core_sys_select() does not.  That's because core_sys_select()
> > > avoids kmalloc by using a buffer on the stack for small allocations (and
> > > 0 sure is small).  Shouldn't compat_core_sys_select() do just the same?
> > > Or is SLUB going to be so efficient that doing so is a waste of time?
> >
> > Nice catch, the original optimisation from Andi is:
> >
> > http://git.kernel.org/git-new/?p=linux/kernel/git/torvalds/linux-2.6.git;a=
> >commit;h=70674f95c0a2ea694d5c39f4e514f538a09be36f
> >
> > And I think it makes sense for the compat code to do it too.
>
> Yes agreed. I just forgot the copy'n'pasted code when doing the original
> change.

Is this headed upstream? It's causing some noise on test.kernel.org
now that SLAB is also warning about kmalloc(0).

Thanks,
Nish
