From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 5/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 12 Nov 2009 21:03:15 -0800
Message-ID: <20091112210315.65a00551@nehalam>
References: <200911130346.nAD3kquT001065@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36999 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788AbZKMFDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 00:03:31 -0500
In-Reply-To: <200911130346.nAD3kquT001065@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 19:46:52 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +#define bfa_cb_queue(__bfa, __hcb_qe, __cbfn, __cbarg) do {		\
> +	(__hcb_qe)->cbfn  = (__cbfn);      \
> +	(__hcb_qe)->cbarg = (__cbarg);      \
> +	list_add_tail(&(__hcb_qe)->qe, &(__bfa)->comp_q);      \
> +} while (0)
> +
> +#define bfa_cb_dequeue(__hcb_qe)	list_del(&(__hcb_qe)->qe)
> +
> +#define bfa_cb_queue_once(__bfa, __hcb_qe, __cbfn, __cbarg) do {	\
> +	(__hcb_qe)->cbfn  = (__cbfn);      \
> +	(__hcb_qe)->cbarg = (__cbarg);      \
> +	if (!(__hcb_qe)->once) {      \
> +		list_add_tail((__hcb_qe), &(__bfa)->comp_q);      \
> +		(__hcb_qe)->once = true;				\
> +	}								\
> +} while (0)
> +
> +#define bfa_cb_queue_done(__hcb_qe) do {				\
> +	(__hcb_qe)->once = false;					\
> +} while (0)
> +

Could these be inline functions or are they typeless macros?


-- 
