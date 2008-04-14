From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.25-rc8-mm2: FIX kmalloc-2048 (was Re: 2.6.25-rc8-mm2: IP:
 [<ffffffff802868f9>] __kmalloc+0x69/0x110)
Date: Mon, 14 Apr 2008 13:05:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804141301580.7803@schroedinger.engr.sgi.com>
References: <20080410203354.f0a6f464.akpm@linux-foundation.org>
 <20080413204422.GA5136@martell.zuzino.mipt.ru>
 <84144f020804140901p1c076fd2q73e3effe7cd96da3@mail.gmail.com>
 <Pine.LNX.4.64.0804141050550.6296@schroedinger.engr.sgi.com>
 <20080414183221.GA5234@martell.zuzino.mipt.ru> <20080414195613.GA4772@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759892AbYDNUFl@vger.kernel.org>
In-Reply-To: <20080414195613.GA4772@martell.zuzino.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Apr 2008, Alexey Dobriyan wrote:

> I can reproduce semi-reliably (by kernel standards) corruption in
> kmalloc-2048. No idea if this can explain all "struct file" related
> oopses I saw, or SLUB free pointer corruption Pekka and Christoph are
> looking into.

The slub free pointer corruption is usually a result of the overwrites.

> Bytes b4 0xffff81017ff9d2c0:  62 ea ff ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a
>   Object 0xffff81017ff9d2d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>   Object 0xffff81017ff9d2e0:  6b 6b 00 18 f3 a2 9f 90 00 1b 38 af 22 49 08 00
>   Object 0xffff81017ff9d2f0:  45 10 00 4c ff 59 40 00 40 11 86 ac c0 a8 00 2a
>   Object 0xffff81017ff9d300:  50 fa a2 be 91 43 00 7b 00 38 54 d4 23 00 00 00
>   Object 0xffff81017ff9d310:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   Object 0xffff81017ff9d320:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>   Object 0xffff81017ff9d330:  00 00 00 00 4c ff 10 44 74 7f 6f 9d e4 c8 a2 4f
>   Object 0xffff81017ff9d340:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  Redzone 0xffff81017ff9dad0:  bb bb bb bb bb bb bb bb
>  Padding 0xffff81017ff9db10:  5a 5a 5a 5a 5a 5a 5a 5a
> 
> FIX kmalloc-2048: Restoring 0xffff81017ff9d2e2-0xffff81017ff9d8d9=0x6b

Looks like skb corruption. Would be helpful to have the complete output 
though. Does the data in the restored range trigger any memories?
