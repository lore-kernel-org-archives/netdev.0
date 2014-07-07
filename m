From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 1/1] tipc: fix a memleak when
	sending data
Date: Mon, 7 Jul 2014 11:28:34 +0800
Message-ID: <53BA13E2.6060800@windriver.com>
References: <1404693530-2531-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Jon Maloy <jon.maloy@ericsson.com>, <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1404693530-2531-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 07/07/2014 08:38 AM, Jon Maloy wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> This fixes a regression bug caused by:
> 067608e9d019d6477fd45dd948e81af0e5bf599f ("tipc: introduce direct
> iovec to buffer chain fragmentation function")
> 
> If data is sent on a nonblocking socket and the destination link
> is congested, the buffer chain is leaked. We fix this by freeing
> the chain in this case.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Acked-by: Ying Xue <ying.xue@windriver.com>

> ---
>  net/tipc/socket.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/tipc/socket.c b/net/tipc/socket.c
> index ede78b1..8c5600c 100644
> --- a/net/tipc/socket.c
> +++ b/net/tipc/socket.c
> @@ -784,8 +784,9 @@ new_mtu:
>  			break;
>  
>  		rc = tipc_wait_for_sndmsg(sock, &timeo);
> +		if (rc)
> +			kfree_skb_list(buf);
>  	} while (!rc);
> -
>  exit:
>  	if (iocb)
>  		release_sock(sk);
> @@ -898,6 +899,8 @@ next:
>  				break;
>  		}
>  		rc = tipc_wait_for_sndpkt(sock, &timeo);
> +		if (rc)
> +			kfree_skb_list(buf);
>  	} while (!rc);
>  exit:
>  	if (iocb)
> 


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
