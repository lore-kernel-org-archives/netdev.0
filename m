From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 8/9] AES: allow modular build
Date: Thu, 28 Oct 2004 10:04:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028090431.GA8193@infradead.org>
References: <200410280721.i9S7Lk908015@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jgarzik@pobox.com, netdev@oss.sgi.com,
        pluto@pld-linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200410280721.i9S7Lk908015@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 28, 2004 at 12:19:47AM -0700, akpm@osdl.org wrote:
> 
> From: <pluto@pld-linux.org>
> 
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  25-akpm/arch/i386/crypto/Makefile |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN arch/i386/crypto/Makefile~aes-allow-modular-build arch/i386/crypto/Makefile
> --- 25/arch/i386/crypto/Makefile~aes-allow-modular-build	2004-10-28 00:17:08.598496816 -0700
> +++ 25-akpm/arch/i386/crypto/Makefile	2004-10-28 00:17:08.603496056 -0700
> @@ -6,4 +6,4 @@
>  
>  obj-$(CONFIG_CRYPTO_AES_586) += aes-i586.o
>  
> -aes-i586-y := aes-i586-asm.o aes.o
> +aes-i586-objs := aes-i586-asm.o aes.o

This doesn't make any sense to me.

foo-objs and foo-y are treated equivalent by the build system, and not
related to modular builds at all.  In fact -y is preffered these days
as it allows to build parts of the multi-object module conditionally using
expressions like:

  foo-y			+= foo_main.o
  foo-$(CONFIG_FOO_BAR) += foo_bar.o
