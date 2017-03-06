From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 11/29] drivers, media: convert cx88_core.refcount from
 atomic_t to refcount_t
Date: Mon, 6 Mar 2017 19:26:23 +0300
Message-ID: <c6987419-f708-9923-0f9f-87b715600045@cogentembedded.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-12-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
 open-iscsi@googlegroups.com, Kees Cook <keescook@chromium.org>,
 linux-scsi@vger.kernel.org, David Windsor <dwindsor@gmail.com>,
 peterz@infradead.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-raid@vger.kernel.org, linux-bcache@vger.kernel.org,
 target-devel@vger.kernel.org, linux-serial@vger.kernel.org,
 devel@linuxdriverproject.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, linux1394-devel@lists.sourceforge.net,
 Hans Liljestrand <ishkamiel@gmail.com>, linux-media@vger.kernel.org
To: Elena Reshetova <elena.reshetova@intel.com>, gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1488810076-3754-12-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hello.

On 03/06/2017 05:20 PM, Elena Reshetova wrote:

> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
>
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>
[...]
> diff --git a/drivers/media/pci/cx88/cx88.h b/drivers/media/pci/cx88/cx88.h
> index 115414c..16c1313 100644
> --- a/drivers/media/pci/cx88/cx88.h
> +++ b/drivers/media/pci/cx88/cx88.h
> @@ -24,6 +24,7 @@
>  #include <linux/i2c-algo-bit.h>
>  #include <linux/videodev2.h>
>  #include <linux/kdev_t.h>
> +#include <linux/refcount.h>
>
>  #include <media/v4l2-device.h>
>  #include <media/v4l2-fh.h>
> @@ -339,7 +340,7 @@ struct cx8802_dev;
>
>  struct cx88_core {
>  	struct list_head           devlist;
> -	atomic_t                   refcount;
> +	refcount_t                   refcount;

    Could you please keep the name aligned with above and below?

>
>  	/* board name */
>  	int                        nr;
>

MBR, Sergei
