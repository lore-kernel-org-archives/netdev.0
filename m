From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: New distributed storage release.
Date: Mon, 8 Sep 2008 23:31:32 +0400
Message-ID: <20080908193132.GB15405@2ka.mipt.ru>
References: <20080908152201.GA14015@2ka.mipt.ru> <alpine.LNX.2.00.0809081818001.19109@titan.stealer.net> <20080908174324.GA18400@2ka.mipt.ru> <alpine.LNX.2.00.0809081948450.19109@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:45340 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421AbYIHTca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 15:32:30 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0809081948450.19109@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 08:19:23PM +0200, Sven Wegener (sven.wegener@stealer.net) wrote:
> > > drivers/block/dst/trans.c:160: warning: format '%llu' expects type 'long long unsigned int', but argument 4 has type 'sector_t'
> > 
> > Yup, sector_t is diffrent depending on arch and config options (u64 vs unsigned long),
> > so it is not possible to represent it correctly without dereferencing
> > to another type.
> 
> Yup, cast it. That are a lot of warnings and best to avoid them.

Yes, warnings have to be removed.

> > > uhm, menuconfig, and then just the debug option there seems wrong.
> > 
> > In case of extended functionality there will be no need to change config
> > options, now it looks like single string in the higher layer config.
> 
> If there is coming more funtionality, ok, but currently it's irritating to 
> have a submenu and then just a single debug option in there.

Nothing is actually planned, I do not care which config option will be
used for that, just do not want to get a new claims on that it should be
changed.

> Yeah, the dprintk()s are ok, but I was after the printk()s that follow. 
> They are unconditional and will always print the key.

Ugh, you are right, I missed that hunk.

> > > sizeof(*req) is preferred, likewise for other sizeof() uses in the code.
> > 
> > No, I do belive that grepping over |struct ablkcipher_request| when
> > something is about to be changed is more convenient, than searching for
> > the structure name and then object name itself.
> > It is matter of a taste though.
> 
> Yeah, but in nearly all cases you don't need to change anything in that 
> line, when you use sizeof(*ptr), because it always gets you the correct 
> size you want. There are cases we could argue about, because you might 
> want to do a limited memset() or memcpy() with a different size, but for 
> most cases like memset() to zero or kmalloc, sizeof(*ptr) makes it clear 
> that you want to clear out the whole structure or you want enough memory 
> to store the type of ptr in it. Don't know how strict the policy is, but 
> it's part of CodingStyle.

Fortunately I missed that flamewar about coding style.

> > I just want to shut up the compiler, since failing to register
> > informational attribute is not critical. But it could also be
> > used to fall the initialization.
> 
> For just shutting up the compiler, use the void cast. I think removing a 
> failed attribute is ok.

If I will ut (void) casting there, I'm pretty sure I will be blamed
not to check th return values, now I check it :)

> > 36 bytes iirc - not that small for stack allocation I think.
> 
> In other cases you allocate u8 iv[32] on the stack, so I guess this point 
> is void. And I think 36 bytes isn't that much and it looks like you're 
> called from user space, so I don't think you have a deep callchain here.

That's a fast path, so I optimized a bit, but I agree, iv initializaion
could be also moved to the preallocated area.
I think connector message can be allocated on stack, since I know the
whole callchain in that path.

I will updated the patch.

-- 
	Evgeniy Polyakov
