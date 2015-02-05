From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next v2] hyper-v: allow access to vmbus from userspace
 driver
Date: Thu, 05 Feb 2015 12:01:03 +0100
Message-ID: <87egq4r5ao.fsf@vitty.brq.redhat.com>
References: <20150204152029.65f02d64@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev@dpdk.org, devel@linuxdriverproject.org,
 Haiyang Zhang <haiyangz@microsoft.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150204152029.65f02d64@urahara> (Stephen Hemminger's message of
 "Wed, 4 Feb 2015 15:20:29 -0800")
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

Stephen Hemminger <stephen@networkplumber.org> writes:

> This is enables the hyper-v driver for DPDK <dev@dpdk.org>.
> The hv_uio driver needs to access the shared vmbus monitor
> pages.

Why can't we just make vmbus_connection struct public?

>
> I would also like to put hv_uio in upstream kernel like other
> uio drivers, but need to get API accepted with DPDK first.
>
> Signed-off-by: Stas Egorov <segorov@mirantis.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
> ---
> v2 - simplify and rename to vmbus_get_monitor_pages
>
>  drivers/hv/connection.c |   20 +++++++++++++++++---
>  include/linux/hyperv.h  |    3 +++
>  2 files changed, 20 insertions(+), 3 deletions(-)
>
> --- a/drivers/hv/connection.c	2015-02-03 10:58:51.751752450 -0800
> +++ b/drivers/hv/connection.c	2015-02-04 14:59:51.636194383 -0800
> @@ -64,6 +64,15 @@ static __u32 vmbus_get_next_version(__u3
>  	}
>  }
>
> +void vmbus_get_monitor_pages(unsigned long *int_page,
> +			     unsigned long monitor_pages[2])
> +{

Too weird to be a public interface in my opinion.

> +	*int_page = (unsigned long)vmbus_connection.int_page;
> +	monitor_pages[0] = (unsigned long)vmbus_connection.monitor_pages[0];
> +	monitor_pages[1] = (unsigned long)vmbus_connection.monitor_pages[1];
> +}
> +EXPORT_SYMBOL_GPL(vmbus_get_monitor_pages);
> +
>  static int vmbus_negotiate_version(struct vmbus_channel_msginfo *msginfo,
>  					__u32 version)
>  {
> @@ -347,10 +356,7 @@ static void process_chn_event(u32 relid)
>  			else
>  				bytes_to_read = 0;
>  		} while (read_state && (bytes_to_read != 0));
> -	} else {
> -		pr_err("no channel callback for relid - %u\n", relid);
>  	}
> -
>  }

This change wasn't mentioned in your commit msg.

>
>  /*
> --- a/include/linux/hyperv.h	2015-02-03 10:58:51.751752450 -0800
> +++ b/include/linux/hyperv.h	2015-02-04 15:00:26.388355012 -0800
> @@ -868,6 +868,9 @@ extern int vmbus_recvpacket_raw(struct v
>
>  extern void vmbus_ontimer(unsigned long data);
>
> +extern void vmbus_get_monitor_pages(unsigned long *int_page,
> +				    unsigned long monitor_pages[2]);
> +
>  /* Base driver object */
>  struct hv_driver {
>  	const char *name;
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

-- 
  Vitaly
