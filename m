From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH] proc_fs.h redux
Date: Sun, 28 Oct 2007 19:58:22 +0200
Message-ID: <200710281858.23705.zippel@linux-m68k.org>
References: <20071027194758.GD9816@martell.zuzino.mipt.ru> <1193524804.26695.103.camel@localhost> <20071028103415.GA12554@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, akpm@osdl.org,
	torvalds@osdl.org, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Russell King <rmk+lkml@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scrub.xs4all.nl ([194.109.195.176]:2206 "EHLO scrub.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbXJ1R72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2007 13:59:28 -0400
In-Reply-To: <20071028103415.GA12554@flint.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sunday 28 October 2007, Russell King wrote:

> On Sat, Oct 27, 2007 at 03:40:04PM -0700, Joe Perches wrote:
> > and forward declarations of
> >
> > struct proc_dir_entry;
> > struct file_operations;
> >
> > As a general rule, I think it better to use includes
> > than use naked forward declarations.
>
> If you go down that route, you end up with _lots_ of circular
> dependencies - header file X needs Y needs Z which needs X.  We've
> been there, several times.  It very quickly becomes quite
> unmaintainable - you end up with hard to predict behaviour from
> include files.
>
> The only realistic solution is to use forward declarations.

It's unfortunately more complicated than that. What basically needs to be done 
is to separate declarations from its users (usually inline functions). The 
problem is to correctly pull the declarations from the <asm/...> and 
<linux/...> header in the correct order. A typical mistake is to put 
declarations and inline functions in the same linux header and then include 
some additional from an asm header. For most high level header it's not much 
of a problem, but let's take <linux/list.h> as example. struct list_head is 
used everywhere, but just to get this one definition one also gets quite a 
few other dependencies as well.

bye, Roman
