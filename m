From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 16/40] netvm: hook skb allocation to reserves
Date: Fri, 4 May 2007 11:07:12 -0300
Message-ID: <39e6f6c70705040707l4556347akb5d5d8fe9282c041@mail.gmail.com>
References: <20070504102651.923946304@chello.nl>
	 <20070504103159.150015136@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Thomas Graf" <tgraf@suug.ch>,
	"David Miller" <davem@davemloft.net>,
	"James Bottomley" <James.Bottomley@steeleye.com>,
	"Mike Christie" <michaelc@cs.wisc.edu>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Daniel Phillips" <phillips@google.com>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.232]:65028 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314AbXEDOHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 10:07:14 -0400
Received: by wr-out-0506.google.com with SMTP id 71so903351wri
        for <netdev@vger.kernel.org>; Fri, 04 May 2007 07:07:13 -0700 (PDT)
In-Reply-To: <20070504103159.150015136@chello.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/4/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Change the skb allocation api to indicate RX usage and use this to fall back to
> the reserve when needed. Skbs allocated from the reserve are tagged in
> skb->emergency.
>
> Teach all other skb ops about emergency skbs and the reserve accounting.
>
> Use the (new) packet split API to allocate and track fragment pages from the
> emergency reserve. Do this using an atomic counter in page->index. This is
> needed because the fragments have a different sharing semantic than that
> indicated by skb_shinfo()->dataref.
>
> (NOTE the extra atomic overhead is only for those pages allocated from the
> reserves - it does not affect the normal fast path.)
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  include/linux/skbuff.h |   22 +++++-
>  net/core/skbuff.c      |  161 ++++++++++++++++++++++++++++++++++++++++++-------
>  2 files changed, 157 insertions(+), 26 deletions(-)

>
> +#define skb_alloc_rx(skb) (skb_emergency(skb) ? SKB_ALLOC_RX : 0)

skb_alloc_rx seems to imply "alloc an skb for rx", not "gimme the
right flags to allocate a skb for rx". Can this be changed to
"skb_alloc_rx_flag(skb)", similar to the existing sock_flag() for
socks?

- Arnaldo
