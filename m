From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next 1/1] hv_netvsc: Use the xmit_more skb flag
 to optimize signaling the host
Date: Sun, 10 May 2015 17:50:57 -0400 (EDT)
Message-ID: <20150510.175057.1320510115648828229.davem@davemloft.net>
References: <1430951345-7767-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1430951345-7767-1-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed,  6 May 2015 15:29:05 -0700

> -		ret = vmbus_sendpacket_pagebuffer(out_channel,
> -						  pgbuf,
> -						  packet->page_buf_cnt,
> -						  &nvmsg,
> -						  sizeof(struct nvsp_message),
> -						  req_id);
> +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
> +						      pgbuf,
> +						      packet->page_buf_cnt,
> +						      &nvmsg,
> +						      sizeof(struct
> +							     nvsp_message),
> +						      req_id,
> +						      vmbus_flags,
> +						      !packet->xmit_more);
>  	} else {
> -		ret = vmbus_sendpacket(
> +		ret = vmbus_sendpacket_ctl(
>  				out_channel, &nvmsg,
>  				sizeof(struct nvsp_message),
>  				req_id,
>  				VM_PKT_DATA_INBAND,
> -				VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
> +				vmbus_flags, !packet->xmit_more);

Just as you did for the vmbus_sendpacket_pagebuffer_ctl() call above,
you'll need to reindent the arguments for the vmbus_sendpacket_ctl()
call since the openning parenthesis is now at a different column.

Thanks.
