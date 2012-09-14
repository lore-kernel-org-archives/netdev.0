From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] Xen backend support for paged out grant targets.
Date: Fri, 14 Sep 2012 08:44:11 -0400
Message-ID: <20120914124411.GB25249@phenom.dumpdata.com>
References: <1347557306-25453-1-git-send-email-andres@lagarcavilla.org>
 <1347559899.25803.64.camel@dagon.hellion.org.uk>
 <B4C805E1-3390-4002-BECC-7D1AFF2BD56D@gmail.com>
 <1347607141.25803.73.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andres Lagar-Cavilla <andres.lagarcavilla@gmail.com>,
	Andres Lagar-Cavilla <andres@lagarcavilla.org>,
	"xen-devel@xen.lists.org" <xen-devel@xen.lists.org>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1347607141.25803.73.camel@dagon.hellion.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 14, 2012 at 08:19:01AM +0100, Ian Campbell wrote:
> On Thu, 2012-09-13 at 20:45 +0100, Andres Lagar-Cavilla wrote:
> > On Sep 13, 2012, at 2:11 PM, Ian Campbell wrote:
> > 
> > > On Thu, 2012-09-13 at 18:28 +0100, Andres Lagar-Cavilla wrote:
> > >> 
> > >> * Add placeholder in array of grant table error descriptions for
> > >> unrelated error code we jump over. 
> > > 
> > > Why not just define it, it's listed here:
> > > http://xenbits.xen.org/docs/unstable/hypercall/include,public,grant_table.h.html#Enum_grant_status
> > Well, a) we'd be defining something no one will be using (for the
> > moment)
> 
> Even if no one in the kernel is using it, having "placeholder" as an
> entry in GNTTABOP_error_msgs is just silly, even things which don't
> understand GNTST_address_too_big directly could end up looking it up
> here.
> 
> >  b) I would be signing-off on something unrelated.
> 
> Lets take this patch instead then.
> 
> 8<------------------------------------------------
> 
> >From cb9daaf3029accb6d5fef58b450a625b27190429 Mon Sep 17 00:00:00 2001
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Fri, 14 Sep 2012 08:10:06 +0100
> Subject: [PATCH] xen: resynchronise grant table status codes with upstream
> 
> Adds GNTST_address_too_big and GNTST_eagain.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

applied.

> ---
>  include/xen/interface/grant_table.h |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/include/xen/interface/grant_table.h b/include/xen/interface/grant_table.h
> index a17d844..84a8fbf 100644
> --- a/include/xen/interface/grant_table.h
> +++ b/include/xen/interface/grant_table.h
> @@ -519,7 +519,9 @@ DEFINE_GUEST_HANDLE_STRUCT(gnttab_get_version);
>  #define GNTST_no_device_space  (-7) /* Out of space in I/O MMU.              */
>  #define GNTST_permission_denied (-8) /* Not enough privilege for operation.  */
>  #define GNTST_bad_page         (-9) /* Specified page was invalid for op.    */
> -#define GNTST_bad_copy_arg    (-10) /* copy arguments cross page boundary */
> +#define GNTST_bad_copy_arg    (-10) /* copy arguments cross page boundary.   */
> +#define GNTST_address_too_big (-11) /* transfer page address too large.      */
> +#define GNTST_eagain          (-12) /* Operation not done; try again.        */
>  
>  #define GNTTABOP_error_msgs {                   \
>      "okay",                                     \
> @@ -532,7 +534,9 @@ DEFINE_GUEST_HANDLE_STRUCT(gnttab_get_version);
>      "no spare translation slot in the I/O MMU", \
>      "permission denied",                        \
>      "bad page",                                 \
> -    "copy arguments cross page boundary"        \
> +    "copy arguments cross page boundary",       \
> +    "page address size too large",              \
> +    "operation not done; try again"             \
>  }
>  
>  #endif /* __XEN_PUBLIC_GRANT_TABLE_H__ */
> -- 
> 1.7.10.4
> 
> 
