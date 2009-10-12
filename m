From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [PATCH] [CAIF-RFC 6/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 15:06:07 +0200
Message-ID: <4AD329BF.9070107@babic.homelinux.org>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-4-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com> <1255095571-6501-7-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout31.attiva.biz ([88.44.63.37]:3356 "EHLO
	smtpout31.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021AbZJLNMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 09:12:48 -0400
In-Reply-To: <1255095571-6501-7-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Hi Sjur,

> +config CAIF_TTY
> +	tristate "CAIF TTY transport driver"
> +	default n
> +	---help---
> +	The CAIF TTY transport driver.
> +	If you say yes here you will also need to build a userspace utility to set the line disicpline on the

s/disicpline/discipline/

> diff --git a/drivers/net/caif/phyif_loop.c b/drivers/net/caif/phyif_loop.c

> +/* Start ring buffer */
> +#define RING_MAX_BUFFERS 16384
> +
> +struct ring_buffer_element {
> +	struct _cfpkt_t *cfpkt;
> +};
> +
> +static struct {
> +	struct ring_buffer_element ring_buffer[RING_MAX_BUFFERS];
> +	int head_index;
> +	int tail_index;
> +} my_ring_buffer;
> +
> +#define ring_buffer_index_plus_one(index) \
> +    ((index+1) < RING_MAX_BUFFERS ? (index + 1) : 0)
> +
> +#define ring_buffer_increment_tail(rb) \
> +    ((rb)->tail_index = ring_buffer_index_plus_one((rb)->tail_index))
> +
> +#define ring_buffer_increment_head(rb) \
> +    ((rb)->head_index = ring_buffer_index_plus_one((rb)->head_index))
> +
> +#define ring_buffer_empty(rb) ((rb)->head_index == (rb)->tail_index)
> +#define ring_buffer_full(rb) (ring_buffer_index_plus_one((rb)->head_index)\
> +			      == (rb)->tail_index)
> +#define ring_buffer_tail_element(rb) ((rb)->ring_buffer[(rb)->tail_index])
> +#define ring_buffer_head_element(rb) ((rb)->ring_buffer[(rb)->head_index])
> +#define ring_buffer_size(rb) (((rb)->head_index >= (rb)->tail_index)) ?\
> +  ((rb)->head_index - (rb)->tail_index) : \
> +    (RING_MAX_BUFFERS - ((rb)->tail_index - (rb)->head_index))
> +/* End ring buffer */

Is there a reason why do you prefer to implement your own ring buffer
management else to use the circ_buf already implemented in kernel ?

> +
> +
> +
> +static void work_func(struct work_struct *work);
> +static struct workqueue_struct *ploop_work_queue;
> +static DECLARE_WORK(loop_work, work_func);
> +static wait_queue_head_t buf_available;
> +
> +
> +#define phyif_assert(assert) BUG_ON(!(assert))

Specialized assert function for this module, really needed ?

> +
> +	result = tty_register_ldisc(N_MOUSE, &phyif_ldisc);

I think it is time to set up your own discipline include/linux/tty.h,
inserting a N_CAIF line discipline. Reusing other discipline conflicts
with other drivers.

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
