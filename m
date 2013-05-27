From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Mon, 27 May 2013 15:25:20 -0700
Message-ID: <1369693520.3301.477.camel@edumazet-glaptop>
References: <1369599557-22677-1-git-send-email-atomlin@redhat.com>
	 <51A39A3F.8080903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: atomlin@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	edumazet@google.com, pshelar@nicira.com, mst@redhat.com,
	alexander.h.duyck@intel.com, aquini@redhat.com,
	sergei.shtylyov@cogentembedded.com, linux-kernel@vger.kernel.org
To: Rik van Riel <riel@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A39A3F.8080903@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-27 at 13:39 -0400, Rik van Riel wrote:
> On 05/26/2013 04:19 PM, atomlin@redhat.com wrote:
> > From: Aaron Tomlin <atomlin@redhat.com>
> >
> > Since v1:
> >   - Removed unnecessary parentheses
> >
> > ---8<---
> >
> > Failed GFP_ATOMIC allocations by the network stack result in dropped
> > packets, which will be received on a subsequent retransmit, and an
> > unnecessary, noisy warning with a kernel backtrace.

This claim is wrong, only some protocols deal with retransmits.

> >
> > These warnings are harmless, but they still cause users to panic and
> > file bug reports over dropped packets. It would be better to hide the
> > failed allocation warnings and backtraces, and let retransmits handle
> > dropped packets quietly.
> 
> Yes please. Getting memory management bug reports for
> dropped network packets got old years ago.  Lets get
> rid of those messages.

I am only wondering why this path has anything needing special
attention, over thousands of kmalloc() like call sites in the kernel.

If mm allocation warnings are useless, just make __GFP_NOWARN the
default, and save us thousand of patches (adding the __GFP_NOWARN
everywhere)

Truth is : some network drivers don't deal very well with allocation
errors. mlx4 for example absolutely wants order-2 pages in RX path, with
no fallback to order-0 pages.

So I am not against this patch, but I can not really acknowledge it,
sorry.
