From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] Drivers: net: hyperv: Cleanup the send path
Date: Thu, 06 Mar 2014 14:30:52 -0500 (EST)
Message-ID: <20140306.143052.1684426326912194946.davem@davemloft.net>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-2-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394104390-23477-2-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Thu,  6 Mar 2014 03:13:06 -0800

> In preparation for enabling offloads, cleanup the send path.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/net/hyperv/hyperv_net.h   |    7 +---
>  drivers/net/hyperv/netvsc_drv.c   |   87 +++++++++++++++++++++++++++++-------
>  drivers/net/hyperv/rndis_filter.c |   66 ----------------------------
>  3 files changed, 71 insertions(+), 89 deletions(-)
> 
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index 39fc230..694bf7c 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -73,7 +73,7 @@ struct hv_netvsc_packet {
>  	} completion;
>  
>  	/* This points to the memory after page_buf */
> -	void *extension;
> +	struct rndis_message *rndis_msg;
>  
>  	u32 total_data_buflen;
>  	/* Points to the send/receive buffer where the ethernet frame is */
> @@ -126,11 +126,6 @@ void rndis_filter_device_remove(struct hv_device *dev);
>  int rndis_filter_receive(struct hv_device *dev,
>  			struct hv_netvsc_packet *pkt);
>  
> -
> -
> -int rndis_filter_send(struct hv_device *dev,
> -			struct hv_netvsc_packet *pkt);
> -
>  int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter);
>  int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac);
>  
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index afa9c53..e812529 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -128,6 +128,28 @@ static int netvsc_close(struct net_device *net)
>  	return ret;
>  }
>  
> +
> +static void *init_ppi_data(struct rndis_message *msg, u32 ppi_size,

One empty line between functions is sufficient.

> @@ -173,7 +195,7 @@ static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
>  	return j + 1;
>  }
>  
> -static void init_page_array(void *hdr, u32 len, struct sk_buff *skb,
> +static u32 init_page_array(void *hdr, u32 len, struct sk_buff *skb,
>  				struct hv_page_buffer *pb)

When you adjust where the openning parenthesis occurs in a function
definition or call, you must adjust the indentation of arguments that
occur on the following lines.

In particular, such arguments must start at exactly the first column
after the openning parenthesis.  You must use the appropriate number
of TAB and space characters necessary to achieve this.
