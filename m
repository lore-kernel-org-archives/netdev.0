From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] net: arcnet: Remove "#define bool int"
Date: Wed, 2 Jul 2014 09:02:50 -0700
Message-ID: <20140702160250.GA2658@kroah.com>
References: <1404303121-2548-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1404303121-2548-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 02, 2014 at 02:12:01PM +0200, Rasmus Villemoes wrote:
> The header file include/linux/arcdevice.h #defines bool to int, if
> bool is not already #defined. However, the files which use that header
> file seem to rely on that #define (unconditionally) being in effect:
> the prototypes for the functions arcrimi_reset, com20020_reset,
> com90io_reset, com90xx_reset (whose addresses are assigned to the
> hw.reset member of struct arcnet_local) use int explicitly.
> 
> Moreover, that #define is an accident waiting to happen (scenario:
> inclusion of arcdevice.h followed by inclusion of some header which
> declares function prototypes using bool). Also, #include
> <linux/types.h> must appear before #include <linux/arcdevice.h> (the
> compiler wouldn't like "typedef _Bool int").
> 
> Since none of the files using arcdevice.h declare variables of type
> "bool", the patch is actually quite simple, unlike the commit message.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  include/linux/arcdevice.h | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)

Why are you sending this patch to me?  I don't "own" it at all, please
use scripts/get_maintainer.pl to determine who to email patches to.

thanks,

greg k-h
