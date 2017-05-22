From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 1/5] sctp: Use kmalloc_array() in sctp_init()
Date: Mon, 22 May 2017 16:57:58 -0400
Message-ID: <c473dc8e-3b13-871a-9b0e-657dd84fd851@redhat.com>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
 <24442429-99f7-7d83-5f56-f84776a81880@users.sourceforge.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <24442429-99f7-7d83-5f56-f84776a81880@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2017 12:37 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 17:20:11 +0200
> 
> * A multiplication for the size determination of a memory allocation
>   indicated that an array data structure should be processed.
>   Thus use the corresponding function "kmalloc_array".
> 
>   This issue was detected by using the Coccinelle software.
> 
> * Replace the specification of a data structure by a pointer dereference
>   to make the corresponding size determination a bit safer according to
>   the Linux coding style convention.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>  net/sctp/protocol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 989a900383b5..2b1a6215bd2f 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -1442,6 +1442,6 @@ static __init int sctp_init(void)
>  
>  	/* Allocate and initialize the endpoint hash table.  */
>  	sctp_ep_hashsize = 64;
> -	sctp_ep_hashtable =
> -		kmalloc(64 * sizeof(struct sctp_hashbucket), GFP_KERNEL);
> +	sctp_ep_hashtable = kmalloc_array(64, sizeof(*sctp_ep_hashtable),
> +					  GFP_KERNEL);
>  	if (!sctp_ep_hashtable) {
> 
