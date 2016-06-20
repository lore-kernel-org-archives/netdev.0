From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Mon, 20 Jun 2016 18:42:32 +0300
Message-ID: <7f753555-eb8d-b902-ade8-efee286fe81b@annapurnalabs.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
 <9B0331B6EBBD0E4684FBFAEDA55776F92CD6858D@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "zorik@annapurnalabs.com" <zorik@annapurnalabs.com>,
	"saeed@annapurnalabs.com" <saeed@annapurnalabs.com>,
	"alex@annapurnalabs.com" <alex@annapurnalabs.com>,
	"msw@amazon.com" <msw@amazon.com>,
	"aligouri@amazon.com" <aliguori@amazon.com>,
	"antoine.tenart@free-electrons.com"
	<antoine.tenart@free-electrons.com>
To: "Rosen, Rami" <rami.rosen@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34888 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbcFTPms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 11:42:48 -0400
Received: by mail-wm0-f48.google.com with SMTP id v199so74555005wmv.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 08:42:40 -0700 (PDT)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F92CD6858D@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/20/2016 08:20 AM, Rosen, Rami wrote:
> Hi all, 
>
> A very limited review below.
>
> +
> +	/* get capabilities of particular feature */
> +	ENA_ADMIN_GET_FEATURE = 8,
>
> Instead /* get capabilities  SHOULD BE:  /* set capabilities .....
> +
> +	/* get capabilities of particular feature */
> +	ENA_ADMIN_SET_FEATURE = 9,
> +
> ..
>
>
> +int ena_com_set_hash_ctrl(struct ena_com_dev *ena_dev)
> +{
> +	struct ena_com_admin_queue *admin_queue = &ena_dev->admin_queue;
> ...
>
> You set ret=-EINVAL, but you do not use this ret as you immediately return 0 in the next line, which is the end of the method. Either return ret or return -EINVAL.
> +	if (unlikely(ret)) {
> +		ena_trc_err("Failed to set hash input. error: %d\n", ret);
> +		ret = -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
I will return ret.
>
>
> +
> +/* ena_com_set_mmio_read_mode - Enable/disable the mmio reg read mechanism
> + * @ena_dev: ENA communication layer struct
>
>
> Instead realess_supported: SHOULD BE: readless_supported
ack
>
> + * @realess_supported: readless mode (enable/disable)
> + */
> +void ena_com_set_mmio_read_mode(struct ena_com_dev *ena_dev,
> +				bool readless_supported);
> +
>
>
>
> +
> +/* ena_com_create_io_queue - Create io queue.
> + * @ena_dev: ENA communication layer struct
>
> Instead ena_com_create_io_ctx SHOULD BE: @ena_com_create_io_ctx
ack
>
> + * ena_com_create_io_ctx - create context structure
> + *
> + * Create the submission and the completion queues.
> + *
> + * @return - 0 on success, negative value on failure.
> + */
> +int ena_com_create_io_queue(struct ena_com_dev *ena_dev,
> +			    struct ena_com_create_io_ctx *ctx);
> +
>
>
>
>
> +/* ena_com_admin_destroy - Destroy IO queue with the queue id - qid.
> + * @ena_dev: ENA communication layer struct
>
> Missing: @qid
ack
>
> + */
> +void ena_com_destroy_io_queue(struct ena_com_dev *ena_dev, u16 qid);
> +
>
> Regards,
> Rami Rosen
> Intel Corporation
Thanks for the review
