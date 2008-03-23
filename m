From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH] kernel: add byteorder macros with alignment fixups
Date: Sun, 23 Mar 2008 14:59:40 +0100
Message-ID: <20080323135939.GC4580@ucw.cz>
References: <1206034454.17059.4.camel@brick> <20080320182911.GQ10722@ZenIV.linux.org.uk> <1206038244.17059.7.camel@brick> <20080320190953.GR10722@ZenIV.linux.org.uk> <1206040953.17059.13.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761185AbYCXQRd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1206040953.17059.13.camel@brick>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 2008-03-20 12:22:33, Harvey Harrison wrote:
> Create linux/unaligned.h to hold a common pattern in the kernel:
> 
> le32_to_cpu(get_unaligned((__le32 *)x));
> 
> Repeat for various combinations of le/be and 64/32/16 bit.  Add
> a variant that operates on possibly unaligned pointers to
> byteorder/generic.h
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> Now the indirect include of asm/unaligned is opt-in when places
> add the linux/unaligned header.
> 
>  include/linux/unaligned.h |   42 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 42 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/unaligned.h b/include/linux/unaligned.h
> new file mode 100644
> index 0000000..7d8fddc
> --- /dev/null
> +++ b/include/linux/unaligned.h
> @@ -0,0 +1,42 @@
> +#ifndef _LINUX_UNALIGNED_H_
> +#define _LINUX_UNALIGNED_H_
> +
> +#include <linux/types.h>
> +#include <asm/byteorder.h>
> +#include <asm/unaligned.h>
> +
> +#ifdef __KERNEL__
> +
> +static inline u64 le64_to_cpu_unaligned(void *p)
> +{
> +	return __le64_to_cpu(get_unaligned((__le64 *)p));
> +}

Why the cast? Should le64_to_cpu() take __le64 * parameter, so that normal
typechecking still works?
							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
