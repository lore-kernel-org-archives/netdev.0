From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v06 18/36] uapi linux/errqueue.h: include linux/time.h in
 user space
Date: Sun, 6 Aug 2017 16:23:16 -0400
Message-ID: <CAF=yD-L2ntuH54J_SwN9WcpBMgkV_v0e-Q2Pu2mrQ3+1RozGFQ@mail.gmail.com>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi> <20170806164428.2273-19-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Network Development <netdev@vger.kernel.org>
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170806164428.2273-19-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 6, 2017 at 12:44 PM, Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
> linux/time.h conflicts with user space header time.h. Try to be compatible
> with both.
>
> Fixes userspace compilation error:
>
> error: array type has incomplete element type
>  struct timespec ts[3];
>
> Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: netdev@vger.kernel.org
> ---
>  include/uapi/linux/errqueue.h | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
> index 07bdce1f444a..b310b2c6d94f 100644
> --- a/include/uapi/linux/errqueue.h
> +++ b/include/uapi/linux/errqueue.h
> @@ -3,6 +3,12 @@
>
>  #include <linux/types.h>
>
> +#ifdef __KERNEL__
> +#include <linux/time.h>
> +#else
> +#include <time.h>
> +#endif /* __KERNEL__ */

This will break applications that include <linux/time.h> manually.

I previously sent a patch to use libc-compat to make compilation succeed
when both are included in the case where <linux/time.h> is included after
<time.h>.

  https://lkml.org/lkml/2016/9/12/872

The inverse will require changes to the libc header to avoid redefining
symbols already defined by <linux/time.h>

The second patch in that 2-patch set included <linux/time.h>
unconditionally after the fix. This broke builds that also included
<time.h> in the wrong order. I did not resubmit the first patch as a
stand-alone, as it is not sufficient to avoid breakage.
