From: Ying Xue <ying.xue0@gmail.com>
Subject: Re: [PATCH] tipc: Use kmemdup instead of kmalloc and memcpy
Date: Mon, 27 Jun 2016 15:37:54 +0800
Message-ID: <5770D7D2.7070204@gmail.com>
References: <20160623044937.GA14109@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>, jon.maloy@ericsson.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160623044937.GA14109@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2016 12:49 PM, Amitoj Kaur Chawla wrote:
> Replace calls to kmalloc followed by a memcpy with a direct call to
> kmemdup.
> 
> The Coccinelle semantic patch used to make this change is as follows:
> @@
> expression from,to,size,flag;
> statement S;
> @@
> 
> -  to = \(kmalloc\|kzalloc\)(size,flag);
> +  to = kmemdup(from,size,flag);
>    if (to==NULL || ...) S
> -  memcpy(to, from, size);
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/server.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/tipc/server.c b/net/tipc/server.c
> index 2446bfb..38a6f33 100644
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
> 
