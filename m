From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH 1/1] tipc: check return value of
	nlmsg_new
Date: Sun, 23 Apr 2017 13:33:09 +0000
Message-ID: <DB5PR0701MB1958A4384C0B9C0571BD1DF99A1C0@DB5PR0701MB1958.eurprd07.prod.outlook.com>
References: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Pan Bian <bianpan2016@163.com>, Ying Xue <ying.xue@windriver.com>, "David
	S. Miller" <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1492931359-25004-1-git-send-email-bianpan2016@163.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Acknowledged. Thank you for doing this job.

///jon


> -----Original Message-----
> From: Pan Bian [mailto:bianpan2016@163.com]
> Sent: Sunday, April 23, 2017 03:09 AM
> To: Jon Maloy <jon.maloy@ericsson.com>; Ying Xue
> <ying.xue@windriver.com>; David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net; linux-
> kernel@vger.kernel.org; Pan Bian <bianpan2016@163.com>
> Subject: [PATCH 1/1] tipc: check return value of nlmsg_new
> 
> Function nlmsg_new() will return a NULL pointer if there is no enough
> memory, and its return value should be checked before it is used.
> However, in function tipc_nl_node_get_monitor(), the validation of the
> return value of function nlmsg_new() is missed. This patch fixes the bug.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>
> ---
>  net/tipc/node.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/tipc/node.c b/net/tipc/node.c index 4512e83..568e48d 100644
> --- a/net/tipc/node.c
> +++ b/net/tipc/node.c
> @@ -2098,6 +2098,8 @@ int tipc_nl_node_get_monitor(struct sk_buff *skb,
> struct genl_info *info)
>  	int err;
> 
>  	msg.skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> +	if (!msg.skb)
> +		return -ENOMEM;
>  	msg.portid = info->snd_portid;
>  	msg.seq = info->snd_seq;
> 
> --
> 1.9.1
> 


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
