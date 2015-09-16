From: Andrzej Hajda <a.hajda@samsung.com>
Subject: Re: [PATCH 27/31] net/tipc: use kmemdup rather than duplicating its
 implementation
Date: Wed, 16 Sep 2015 12:07:17 +0200
Message-ID: <55F93F55.70505@samsung.com>
References: <1438934377-4922-1-git-send-email-a.hajda@samsung.com>
 <1438934377-4922-28-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1438934377-4922-28-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ping.

Regards
Andrzej

On 08/07/2015 09:59 AM, Andrzej Hajda wrote:
> The patch was generated using fixed coccinelle semantic patch
> scripts/coccinelle/api/memdup.cocci [1].
>
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2014320
>
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> ---
>  net/tipc/server.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/tipc/server.c b/net/tipc/server.c
> index 922e04a..c187cad 100644
> --- a/net/tipc/server.c
> +++ b/net/tipc/server.c
> @@ -411,13 +411,12 @@ static struct outqueue_entry *tipc_alloc_entry(void *data, int len)
>  	if (!entry)
>  		return NULL;
>  
> -	buf = kmalloc(len, GFP_ATOMIC);
> +	buf = kmemdup(data, len, GFP_ATOMIC);
>  	if (!buf) {
>  		kfree(entry);
>  		return NULL;
>  	}
>  
> -	memcpy(buf, data, len);
>  	entry->iov.iov_base = buf;
>  	entry->iov.iov_len = len;
>  
