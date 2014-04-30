From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH V1 net-next 1/1] hyperv: Enable sendbuf mechanism on the
 send path
Date: Wed, 30 Apr 2014 21:51:17 +0300
Message-ID: <20140430185116.GH26890@mwanda>
References: <1398878071-21307-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 davem@davemloft.net
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1398878071-21307-1-git-send-email-kys@microsoft.com>
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

On Wed, Apr 30, 2014 at 10:14:31AM -0700, K. Y. Srinivasan wrote:
> +	/* Setup state for managing the send buffer. */
> +	net_device->map_words = DIV_ROUND_UP(net_device->send_section_cnt,
> +					     BITS_PER_LONG);
> +
> +	net_device->send_section_map =
> +		kzalloc(net_device->map_words * sizeof(ulong), GFP_KERNEL);
> +	if (net_device->send_section_map == NULL)
> +		goto cleanup;

I told you about this returning success bug if kmalloc() fails but you
didn't fix it.

> +
>  	goto exit;
>  
>  cleanup:
> -	netvsc_destroy_recv_buf(net_device);
> +	netvsc_destroy_buf(net_device);
>  
>  exit:
>  	return ret;

regards,
dan carpenter
