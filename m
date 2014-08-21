From: "Zhouyi Zhou" <yizhouzhou@ict.ac.cn>
Subject: Re: [PATCH 1/1] netfilter/jump_label: use HAVE_JUMP_LABEL?
Date: Thu, 21 Aug 2014 20:53:19 +0800 (GMT+08:00)
Message-ID: <1498523.4b875.147f8a0e3c8.Coremail.yizhouzhou@ict.ac.cn>
References: <1408589568-27046-1-git-send-email-yizhouzhou@ict.ac.cn>
 <20140821121132.GA16498@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Zhouyi Zhou" <zhouzhouyi@gmail.com>, pablo@netfilter.org,
	kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbaron@akamai.com
To: "Florian Westphal" <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821121132.GA16498@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Florian for reviewing

> -----Original Messages-----
> From: "Florian Westphal" <fw@strlen.de>

> 
> Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> > 
> > CONFIG_JUMP_LABEL doesn't ensure HAVE_JUMP_LABEL, if it
> > is not the case use maintainers's own mutex to guard
> > the modification of global values.

CONFIG_JUMP_LABEL says the user wants to use jump labels.
But we also need the toolchain to support it.

That is reflected in CC_HAVE_ASM_GOTO=y, and if both are
set then HAVE_JUMP_LABEL is set to true.

> I don't understand this patch.
> 
> What is the problem you are fixing?

There is basically no real problem here.
This patch only tries to make kernel code that using 
static_key infrastructure appears "unified"
> 
> The intent is to only use static_key infrastructure
> if user has enabled CONFIG_JUMP_LABEL.

The other parts of kernel either use #ifdef HAVE_JUMP_LABEL,
or use no "#ifdef" at all(the two exceptions are netfilter 
and powerpc modules which I send patches to both).

Jason has suggested me to make the patches:
https://lkml.org/lkml/2014/8/20/761

"Unified" is the reason, I guess :-)
so rookies like me can have unified examples to follow


 
Cheers
Zhouyi
