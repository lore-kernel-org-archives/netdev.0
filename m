From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/5] RDMA/cxgb4: Cleanup Filter related
 macros/register defines
Date: Thu, 20 Nov 2014 23:55:54 -0800
Message-ID: <1416556554.6651.35.camel@perches.com>
References: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
	 <1416554525-11844-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	roland@purestorage.com, JBottomley@parallels.com,
	hch@infradead.org, swise@opengridcomputing.com, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	praveen@chelsio.com, varun@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0186.hostedemail.com ([216.40.44.186]:47294 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752098AbaKUHz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 02:55:59 -0500
In-Reply-To: <1416554525-11844-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-21 at 12:52 +0530, Hariprasad Shenai wrote:
> This patch cleanups all filter related macros/register defines that are defined
> in t4fw_api.h and the affected files.

Is there any real value in the FW_FILTER_WR_ prefix?
Does it need to be so long?

Perhaps it'd be nicer to read if
_S was _SHIFT
_M was _MASK
_V was whatever it's supposed to represent (_SET?)
and
_G was _GET

> +#define FW_FILTER_WR_TID_S      12
> +#define FW_FILTER_WR_TID_M      0xfffff
> +#define FW_FILTER_WR_TID_V(x)   ((x) << FW_FILTER_WR_TID_S)
> +#define FW_FILTER_WR_TID_G(x)   \
> +	(((x) >> FW_FILTER_WR_TID_S) & FW_FILTER_WR_TID_M)

Why aren't the _V defines masked then shifted?

#define FW_FILTER_WR_<foo>_V(x)				\
	(((x) & FW_FILTER_<foo>_M) << FW_FILTER_<foo>_S)
