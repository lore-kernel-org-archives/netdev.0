From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 4/4] Netfilter: xt_LOG: Implement ring buffer support
Date: Tue, 14 Feb 2012 01:11:23 +0100
Message-ID: <20120214001123.GA24194@1984>
References: <1328911856-19260-1-git-send-email-richard@nod.at>
 <1328911856-19260-7-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org, basti@b-bl.de
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1328911856-19260-7-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 10, 2012 at 11:10:56PM +0100, Richard Weinberger wrote:
> This patch introduces NETFILTER_XT_TARGET_LOG_RING.
> It allows logging into various ring buffers which are
> represented as pipe-like files in /proc/net/netfilter/xt_LOG_ring/.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>  include/linux/netfilter/xt_LOG.h    |   13 +-
>  include/net/netfilter/nf_log.h      |    1 +
>  include/net/netfilter/xt_log_ring.h |   24 ++

Could merge xt_log_ring.h with xt_log.h?

>  net/netfilter/Kconfig               |   13 +
>  net/netfilter/xt_LOG.c              |  642 ++++++++++++++++++++++++++++++++++-
>  5 files changed, 674 insertions(+), 19 deletions(-)
>  create mode 100644 include/net/netfilter/xt_log_ring.h
> 
> diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilter/xt_LOG.h
> index cac0790..d84710c 100644
> --- a/include/linux/netfilter/xt_LOG.h
> +++ b/include/linux/netfilter/xt_LOG.h
> @@ -8,7 +8,8 @@
>  #define XT_LOG_UID		0x08	/* Log UID owning local socket */
>  #define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
>  #define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
> -#define XT_LOG_MASK		0x2f
> +#define XT_LOG_ADD_TIMESTAMP	0x40	/* Add a timestamp */

Please, I'd appreciate if you can split this timestamp support in a
separated patch.

Thanks.
