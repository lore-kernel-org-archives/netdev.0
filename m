From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Fix possible NULL pointer dereference
Date: Mon, 25 Feb 2013 09:09:43 -0300
Message-ID: <20130225120943.GA4830@oc0268524204.ibm.com>
References: <1361746798-29215-1-git-send-email-s.syam@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Syam Sidhardhan <syamsidhardh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:60806 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756167Ab3BYMJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 07:09:51 -0500
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 25 Feb 2013 09:09:49 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id C1C903520055
	for <netdev@vger.kernel.org>; Mon, 25 Feb 2013 07:09:45 -0500 (EST)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1PC93e631850746
	for <netdev@vger.kernel.org>; Mon, 25 Feb 2013 09:09:04 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1PC9iHm004937
	for <netdev@vger.kernel.org>; Mon, 25 Feb 2013 09:09:45 -0300
Content-Disposition: inline
In-Reply-To: <1361746798-29215-1-git-send-email-s.syam@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2013 at 04:29:58AM +0530, Syam Sidhardhan wrote:
> Check for (queue == NULL) has to be done before accessing queue.
> 
> Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
> ---
>  drivers/net/ethernet/ibm/ehea/ehea_qmr.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
> index 9b03033..a0820f7 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
> @@ -103,12 +103,14 @@ out_nomem:
> 
>  static void hw_queue_dtor(struct hw_queue *queue)
>  {
> -	int pages_per_kpage = PAGE_SIZE / queue->pagesize;
> +	int pages_per_kpage;
>  	int i, nr_pages;
> 
>  	if (!queue || !queue->queue_pages)
>  		return;
> 
> +	pages_per_kpage = PAGE_SIZE / queue->pagesize;
> +
>  	nr_pages = queue->queue_length / queue->pagesize;
> 
>  	for (i = 0; i < nr_pages; i += pages_per_kpage)
> -- 
> 1.7.9.5
> 

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
