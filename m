From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 20 Jan 2009 13:00:43 +0300
Message-ID: <20090120100043.GA9167@ioremap.net>
References: <20090114.012919.117682429.davem@davemloft.net> <20090115230331.GB1123@1wt.eu> <20090115231934.GA8328@gondor.apana.org.au> <20090115.152608.89323697.davem@davemloft.net> <20090120083726.GA13806@ff.dom.local> <20090120093352.GB13806@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	w@1wt.eu, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:44273 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907AbZATKAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 05:00:40 -0500
Content-Disposition: inline
In-Reply-To: <20090120093352.GB13806@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek.

On Tue, Jan 20, 2009 at 09:33:52AM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > Here is a tiny upgrade to save some memory by reusing a page for more
> > chunks if possible, which I think could be considered, after the
> > testing of the main patch is finished. (There could be also added an
> > additional freeing of this cached page before socket destruction,
> > maybe in tcp_splice_read(), if somebody finds good place.)
> 
> OOPS! I did it again... Here is better refcounting.
> 
> Jarek P.
> 
> --- (take 2)
> 
>  include/net/sock.h  |    4 ++++
>  net/core/skbuff.c   |   32 ++++++++++++++++++++++++++------
>  net/core/sock.c     |    2 ++
>  net/ipv4/tcp_ipv4.c |    8 ++++++++
>  4 files changed, 40 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 5a3a151..4ded741 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -190,6 +190,8 @@ struct sock_common {
>    *	@sk_user_data: RPC layer private data
>    *	@sk_sndmsg_page: cached page for sendmsg
>    *	@sk_sndmsg_off: cached offset for sendmsg
> +  *	@sk_splice_page: cached page for splice
> +  *	@sk_splice_off: cached offset for splice

Ugh, increase every socket by 16 bytes... Does TCP one still fit the
page?

-- 
	Evgeniy Polyakov
