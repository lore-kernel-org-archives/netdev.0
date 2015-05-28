From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] hv_netvsc: Allocate the receive buffer from the
 correct NUMA node
Date: Thu, 28 May 2015 22:29:12 +0000
Message-ID: <BY2PR0301MB0711AD5DF4A1FE2EFFA2EEB0A0CA0@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1432850186-31770-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: KY Srinivasan <kys@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0119.outbound.protection.outlook.com ([157.56.111.119]:49811
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754713AbbE1W3W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 18:29:22 -0400
In-Reply-To: <1432850186-31770-1-git-send-email-kys@microsoft.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: K. Y. Srinivasan [mailto:kys@microsoft.com]
> Sent: Thursday, May 28, 2015 2:56 PM
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Cc: KY Srinivasan
> Subject: [PATCH 1/1] hv_netvsc: Allocate the receive buffer from the correct
> NUMA node
> 
> Allocate the receive bufer from the NUMA node assigned to the primary
> channel.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index b024968..d187965 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -227,13 +227,18 @@ static int netvsc_init_buf(struct hv_device *device)
>  	struct netvsc_device *net_device;
>  	struct nvsp_message *init_packet;
>  	struct net_device *ndev;
> +	int node;
> 
>  	net_device = get_outbound_net_device(device);
>  	if (!net_device)
>  		return -ENODEV;
>  	ndev = net_device->ndev;
> 
> -	net_device->recv_buf = vzalloc(net_device->recv_buf_size);
> +	node = cpu_to_node(device->channel->target_cpu);
> +	net_device->recv_buf = vzalloc_node(net_device->recv_buf_size,
> node);
> +	if (!net_device->recv_buf)
> +		net_device->recv_buf = vzalloc(net_device->recv_buf_size);
> +
>  	if (!net_device->recv_buf) {
>  		netdev_err(ndev, "unable to allocate receive "
>  			"buffer of size %d\n", net_device->recv_buf_size);
> --
> 1.7.4.1

David,

Please drop this patch; I am going to resend this with another patch.

Regards,

K. Y
