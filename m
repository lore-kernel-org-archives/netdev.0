From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH v2 net] nfc: close a race condition in llcp_sock_getname()
Date: Thu, 25 Feb 2016 08:43:44 +0100
Message-ID: <20160225074344.GB9068@zurbaran.home>
References: <1454096260-20396-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	linux-wireless@vger.kernel.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6842 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759551AbcBYHnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 02:43:45 -0500
Content-Disposition: inline
In-Reply-To: <1454096260-20396-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Fri, Jan 29, 2016 at 11:37:40AM -0800, Cong Wang wrote:
> llcp_sock_getname() checks llcp_sock->dev to make sure
> llcp_sock is already connected or bound, however, we could
> be in the middle of llcp_sock_bind() where llcp_sock->dev
> is bound and llcp_sock->service_name_len is set,
> but llcp_sock->service_name is not, in this case we would
> lead to copy some bytes from a NULL pointer.
> 
> Just lock the sock since this is not a hot path anyway.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
> Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/nfc/llcp_sock.c | 6 ++++++
>  1 file changed, 6 insertions(+)
Applied as well, thanks.

Cheers,
Samuel.
