From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] proc_fs.h redux
Date: Sun, 28 Oct 2007 10:02:26 +0300
Message-ID: <20071028070226.GA23097@martell.zuzino.mipt.ru>
References: <20071027194758.GD9816@martell.zuzino.mipt.ru> <1193524804.26695.103.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, torvalds@osdl.org, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:43571 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbXJ1HDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 03:03:03 -0400
Received: by ug-out-1314.google.com with SMTP id z38so857996ugc
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2007 00:03:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1193524804.26695.103.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 27, 2007 at 03:40:04PM -0700, Joe Perches wrote:
> On Sat, 2007-10-27 at 23:47 +0400, Alexey Dobriyan wrote:
> > Remove proc_fs.h from headers that doesn't really need it.
> 
> > --- a/arch/powerpc/kernel/process.c
> > +++ b/arch/powerpc/kernel/process.c
> > @@ -17,6 +17,7 @@
> >  #include <linux/errno.h>
> >  #include <linux/sched.h>
> >  #include <linux/kernel.h>
> > +#include <linux/fs.h>
> 
> Your code doesn't match your patch description.
> 
> You've got new includes of:
> 
> <linux/fs.h>
> <linux/proc_fs.h>
> <linux/err.h>
> <linux/kref.h>
> 
> and forward declarations of
> 
> struct proc_dir_entry;
> struct file_operations;

Removal of header A from header B creates compilation breakages for
files which were getting A indirectly. So you have to complensate in all
such cases.

> As a general rule, I think it better to use includes
> than use naked forward declarations.

Well, we also want faster compilation and less time wasted when
test-compiling patches.
