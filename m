From: =?utf-8?q?Pawe=C5=82_Sikora?= <pluto@pld-linux.org>
Subject: Re: [patch 8/9] AES: allow modular build
Date: Thu, 28 Oct 2004 18:57:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410281857.50354.pluto@pld-linux.org>
References: <200410280721.i9S7Lk908015@mail.osdl.org> <20041028090431.GA8193@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, davem@redhat.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041028090431.GA8193@infradead.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 28 of October 2004 11:04, Christoph Hellwig wrote:
> On Thu, Oct 28, 2004 at 12:19:47AM -0700, akpm@osdl.org wrote:
> > From: <pluto@pld-linux.org>
> >
> >
> > Signed-off-by: Andrew Morton <akpm@osdl.org>
> > ---
> >
> >  25-akpm/arch/i386/crypto/Makefile |    2 +-
> >  1 files changed, 1 insertion(+), 1 deletion(-)
> >
> > diff -puN arch/i386/crypto/Makefile~aes-allow-modular-build
> > arch/i386/crypto/Makefile ---
> > 25/arch/i386/crypto/Makefile~aes-allow-modular-build 2004-10-28
> > 00:17:08.598496816 -0700 +++ 25-akpm/arch/i386/crypto/Makefile 2004-10-28
> > 00:17:08.603496056 -0700 @@ -6,4 +6,4 @@
> >
> >  obj-$(CONFIG_CRYPTO_AES_586) += aes-i586.o
> >
> > -aes-i586-y := aes-i586-asm.o aes.o
> > +aes-i586-objs := aes-i586-asm.o aes.o
>
> This doesn't make any sense to me.
> foo-objs and foo-y are treated equivalent by the build system, and not
> related to modular builds at all.  In fact -y is preffered these days
> as it allows to build parts of the multi-object module conditionally using
> expressions like:
>
>   foo-y   += foo_main.o
>   foo-$(CONFIG_FOO_BAR) += foo_bar.o

Hmm,
Without my fix the 2.6.8rc[34] produced unresolved symbol
in the AES module. With this fix the problem didn't exist.
Now (2.6.10rc1) it works fine without this fix.
Where was the problem? [1] -y/-objs | [2] AES module.

-- 
/* Copyright (C) 2003, SCO, Inc. This is valuable Intellectual Property. */

                           #define say(x) lie(x)
