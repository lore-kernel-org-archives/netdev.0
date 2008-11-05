From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Wed, 5 Nov 2008 12:54:28 +0300
Message-ID: <20081105095428.GA4584@x200.localdomain>
References: <20081101.213315.01349801.davem@davemloft.net> <20081103001643.GA22217@x200.localdomain> <20081103010431.GA29905@gondor.apana.org.au> <20081105.013148.156667310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:16189 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384AbYKEJvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:51:12 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1788846ika.5
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 01:51:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081105.013148.156667310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2008 at 01:31:48AM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 3 Nov 2008 09:04:31 +0800
> 
> > On Mon, Nov 03, 2008 at 03:16:43AM +0300, Alexey Dobriyan wrote:
> > >
> > > Keep in mind that the only error message is "line N: returned (null)"
> > > from setkey(8) or something like that and no SA created.
> > > 
> > > It took me full printk session to realize what's going on.
> > 
> > As our error passing really sucks, I'm happy to accept a patch
> > to crypto_alloc_tfm which prints out a message if it fails.
> 
> As we've discussed several times it's not "passing" errors
> that sucks, it's the fact that we use the same traditional
> UNIX error codes for a thousand different errors. :-)
> 
> I really think we should explore the idea where the current
> process can get tagged with a string when an error is going
> to be returned.  Something like:
> 
> 	const char *error_desc;
> 
> in the task_struct.
> 
> So when you return an error, you also can mark the task with
> some descriptive text that describes what is wrong.

rmmod in between and error_desc points to garbage. But that's for
somebody who is going to implement this. :-)

> A task is guarenteed that when an error returns from a system
> call and the very next system call they make is "sys_get_error"
> or whatever we'll call it, they will the correct value of
> current->error_desc
> 
> This way you don't just get "-EINVAL" returned from a
> complicated IPSEC configuration operation request.

It was ENOENT from crypto_alg_mod_lookup(), actually.

I think liberal printk additions are the way to go.
