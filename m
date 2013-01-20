From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 01/21] NTB: correct missing readq/writeq errors
Date: Sun, 20 Jan 2013 15:40:05 -0800
Message-ID: <20130120234005.GA14196@kroah.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-2-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358586155-23322-2-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 19, 2013 at 02:02:15AM -0700, Jon Mason wrote:
> Atomic readq and writeq do not exist by default on some 32bit
> architectures, thus causing compile errors due to non-existent symbols.
> In those cases, use the definitions of those symbols from
> include/asm-generic/io-64-nonatomic-hi-lo.h
> 
> Signed-off-by: Jon Mason <jon.mason@intel.com>
> ---
>  drivers/ntb/ntb_hw.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> index 4c71b17..0b46fef 100644
> --- a/drivers/ntb/ntb_hw.c
> +++ b/drivers/ntb/ntb_hw.c
> @@ -45,6 +45,7 @@
>   * Contact Information:
>   * Jon Mason <jon.mason@intel.com>
>   */
> +#include <asm-generic/io-64-nonatomic-hi-lo.h>

Really?  This seems really odd.  Usually we just don't build the code
for any platform that doesn't have readq/writeq.  Otherwise, shouldn't
those arches just include this file themselves to keep everything
working?  Individual drivers shouldn't have to do this.

So, I'm not going to take this one just yet, sorry.

greg k-h
