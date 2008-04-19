From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.25-rc8-mm2: FIX kmalloc-2048 (was Re: 2.6.25-rc8-mm2: IP:
	[<ffffffff802868f9>] __kmalloc+0x69/0x110)
Date: Sat, 19 Apr 2008 15:17:19 +0400
Message-ID: <20080419111719.GA6724@martell.zuzino.mipt.ru>
References: <20080410203354.f0a6f464.akpm@linux-foundation.org> <20080413204422.GA5136@martell.zuzino.mipt.ru> <84144f020804140901p1c076fd2q73e3effe7cd96da3@mail.gmail.com> <Pine.LNX.4.64.0804141050550.6296@schroedinger.engr.sgi.com> <20080414183221.GA5234@martell.zuzino.mipt.ru> <20080414195613.GA4772@martell.zuzino.mipt.ru> <Pine.LNX.4.64.0804141301580.7803@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:29815 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342AbYDSKVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 06:21:52 -0400
Received: by ug-out-1314.google.com with SMTP id z38so251002ugc.16
        for <netdev@vger.kernel.org>; Sat, 19 Apr 2008 03:21:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804141301580.7803@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 14, 2008 at 01:05:09PM -0700, Christoph Lameter wrote:
> On Mon, 14 Apr 2008, Alexey Dobriyan wrote:
> 
> > I can reproduce semi-reliably (by kernel standards) corruption in
> > kmalloc-2048. No idea if this can explain all "struct file" related
> > oopses I saw, or SLUB free pointer corruption Pekka and Christoph are
> > looking into.
> 
> The slub free pointer corruption is usually a result of the overwrites.
> 
> > Bytes b4 0xffff81017ff9d2c0:  62 ea ff ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a
> >   Object 0xffff81017ff9d2d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> >   Object 0xffff81017ff9d2e0:  6b 6b 00 18 f3 a2 9f 90 00 1b 38 af 22 49 08 00
> >   Object 0xffff81017ff9d2f0:  45 10 00 4c ff 59 40 00 40 11 86 ac c0 a8 00 2a
> >   Object 0xffff81017ff9d300:  50 fa a2 be 91 43 00 7b 00 38 54 d4 23 00 00 00
> >   Object 0xffff81017ff9d310:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >   Object 0xffff81017ff9d320:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >   Object 0xffff81017ff9d330:  00 00 00 00 4c ff 10 44 74 7f 6f 9d e4 c8 a2 4f
> >   Object 0xffff81017ff9d340:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >  Redzone 0xffff81017ff9dad0:  bb bb bb bb bb bb bb bb
> >  Padding 0xffff81017ff9db10:  5a 5a 5a 5a 5a 5a 5a 5a
> > 
> > FIX kmalloc-2048: Restoring 0xffff81017ff9d2e2-0xffff81017ff9d8d9=0x6b
> 
> Looks like skb corruption. Would be helpful to have the complete output 
> though. Does the data in the restored range trigger any memories?

No.

I'm currently tracing this bug and 2.6.24 also has it. :-(

