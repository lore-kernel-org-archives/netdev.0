From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] tipc:Make the function
 tipc_buf_append have a return type of bool
Date: Thu, 18 Jun 2015 10:56:45 +0800
Message-ID: <5582336D.9020402@windriver.com>
References: <1434595459-24040-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>, <jon.maloy@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1434595459-24040-1-git-send-email-xerofoify@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 06/18/2015 10:44 AM, Nicholas Krause wrote:
> This converts the function tipc_buf_append now due to this
> particular function only returning either one or zero as
> its return value.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/msg.c | 12 ++++++------
>  net/tipc/msg.h |  2 +-
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/tipc/msg.c b/net/tipc/msg.c
> index c3e96e8..52f2978 100644
> --- a/net/tipc/msg.c
> +++ b/net/tipc/msg.c
> @@ -115,9 +115,9 @@ struct sk_buff *tipc_msg_create(uint user, uint type,
>   *            out: set when successful non-complete reassembly, otherwise NULL
>   * @*buf:     in:  the buffer to append. Always defined
>   *            out: head buf after successful complete reassembly, otherwise NULL
> - * Returns 1 when reassembly complete, otherwise 0
> + * Returns true when reassembly complete, otherwise false
>   */
> -int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
> +bool tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
>  {
>  	struct sk_buff *head = *headbuf;
>  	struct sk_buff *frag = *buf;
> @@ -144,7 +144,7 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
>  		skb_frag_list_init(head);
>  		TIPC_SKB_CB(head)->tail = NULL;
>  		*buf = NULL;
> -		return 0;
> +		return false;
>  	}
>  
>  	if (!head)
> @@ -171,16 +171,16 @@ int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
>  		*buf = head;
>  		TIPC_SKB_CB(head)->tail = NULL;
>  		*headbuf = NULL;
> -		return 1;
> +		return true;
>  	}
>  	*buf = NULL;
> -	return 0;
> +	return false;
>  err:
>  	pr_warn_ratelimited("Unable to build fragment list\n");
>  	kfree_skb(*buf);
>  	kfree_skb(*headbuf);
>  	*buf = *headbuf = NULL;
> -	return 0;
> +	return false;
>  }
>  
>  /* tipc_msg_validate - validate basic format of received message
> diff --git a/net/tipc/msg.h b/net/tipc/msg.h
> index e1d3595e..00d3357 100644
> --- a/net/tipc/msg.h
> +++ b/net/tipc/msg.h
> @@ -771,7 +771,7 @@ void tipc_msg_init(u32 own_addr, struct tipc_msg *m, u32 user, u32 type,
>  struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
>  				uint data_sz, u32 dnode, u32 onode,
>  				u32 dport, u32 oport, int errcode);
> -int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
> +bool tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
>  bool tipc_msg_bundle(struct sk_buff *bskb, struct sk_buff *skb, u32 mtu);
>  
>  bool tipc_msg_make_bundle(struct sk_buff **skb, u32 mtu, u32 dnode);
> 


------------------------------------------------------------------------------
