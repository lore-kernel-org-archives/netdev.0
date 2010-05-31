From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Mon, 31 May 2010 08:08:13 -0700
Message-ID: <1275318493.6503.206.camel@Joe-Laptop.home>
References: <alpine.OSX.2.00.1004171258330.358@localhost>
	 <20100421.163041.158540277.davem@davemloft.net>
	 <alpine.OSX.2.00.1005290255580.691@localhost>
	 <20100531.001947.193703044.davem@davemloft.net>
	 <alpine.LNX.2.00.1005311905520.469@nippy.intranet>
	 <AANLkTilkooBglbk33yDHmk8c_ZdlamOW8FVvuvjQaNsF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fthain@telegraphics.com.au, David Miller <davem@davemloft.net>,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <AANLkTilkooBglbk33yDHmk8c_ZdlamOW8FVvuvjQaNsF@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-05-31 at 11:58 +0200, Geert Uytterhoeven wrote:
> > To make it plain: there are 25 files or so that use ei_debug. Three of
> > those that now have the KERN_DEBUG printk's suppresed by the DEBUG macro
> > only do so as an apparently unintended side effect of a commit that claims
> > to "implement dynmic debug infrastructure". (Go figure.)
> >
> > http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=dd0fab5b940c0b65f26ac5b01485bac1f690ace6
> >
> > Your suggestion to use pr_debug is invoking compile time infrastructure
> > (the DEBUG macro), so it is not in the spirit of this commit, and it is
> > not relevant to any criticism from you or Joe of the earlier submissions.
> >
> > Please apply the patch.
> 
> `pr_debug()' indeed now may generate code if DEBUG is not defined,
> i.e. if CONFIG_DYNAMIC_DEBUG is enabled.
> This is intented for debug infrastructure the user may want to enable later.
> 
> If you want the old behavior, you can use `pr_devel()' instead, which
> only generates code if DEBUG is defined.
> This is intended for debug infrastructure for developers only.
> 
> However, you used `printk(KERN_DEBUG pr_fmt()...)`, which always generates code.
> I'm still not 100% sure that was intentional?

There are many uses of KERN_DEBUG that are reasonable to have
always enabled.

There is no pr_<level> macro/function that is always enabled.

David, would you accept a new pr_<level> in kernel.h
for that purpose?

If so, do you have an opinion what it should be named?

I think pr_dbg is not ideal as dev_dbg is already in use
and can get optimized away.

Maybe one of:

	pr_always_dbg
	pr_dbg_always
	pr_dbg_noopt
	pr_tdbg

or something better?  Anyone else?

http://lkml.org/lkml/2009/10/1/399
