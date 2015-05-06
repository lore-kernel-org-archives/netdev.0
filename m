From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next] tipc: allow one link per bearer to neighboring
 nodes
Date: Wed, 6 May 2015 19:45:18 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C3F0AC1@eusaamb103.ericsson.se>
References: <1415986399-23874-1-git-send-email-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Holger Brunck <holger.brunck@keymile.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:47827 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbbEFUAX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 16:00:23 -0400
In-Reply-To: <1415986399-23874-1-git-send-email-holger.brunck@keymile.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Holger,
I am trying to remember why you wanted to have this, especially since it
didn't change anything in practice, because MAX_BEARERS is still 2.

This limit has to be changed, since we may want to have e.g. dual Ethernet
links to some nodes and single UDP links to others (but never the same)

Despite this, I can find good reasons to not allow more than two links 
between a node pair. (In particular, the failover mechanism becomes 
much more complex)

Can you please reiterate why you see a need for this?

Regards
///jon


> -----Original Message-----
> From: Holger Brunck [mailto:holger.brunck@keymile.com]
> Sent: Friday, November 14, 2014 12:33 PM
> To: davem@davemloft.net
> Cc: Jon Maloy; Holger Brunck; Ying Xue; Erik Hugne; netdev@vger.kernel.org
> Subject: [PATCH net-next] tipc: allow one link per bearer to neighboring
> nodes
> 
> There is no reason to limit the amount of possible links to a neighboring node
> to 2. If we have more then two bearers we can also establish more links.
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
> Reviewed-By: Jon Maloy <jon.maloy@ericsson.com>
> cc: Ying Xue <ying.xue@windriver.com>
> cc: Erik Hugne <erik.hugne@ericsson.com>
> cc: netdev@vger.kernel.org
> ---
>  net/tipc/link.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/tipc/link.c b/net/tipc/link.c index 1db162a..7cf8004 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -224,9 +224,10 @@ struct tipc_link *tipc_link_create(struct tipc_node
> *n_ptr,
>  	char addr_string[16];
>  	u32 peer = n_ptr->addr;
> 
> -	if (n_ptr->link_cnt >= 2) {
> +	if (n_ptr->link_cnt >= MAX_BEARERS) {
>  		tipc_addr_string_fill(addr_string, n_ptr->addr);
> -		pr_err("Attempt to establish third link to %s\n", addr_string);
> +		pr_err("Attempt to establish %uth link to %s. Max %u
> allowed.\n",
> +			n_ptr->link_cnt, addr_string, MAX_BEARERS);
>  		return NULL;
>  	}
> 
> --
> 2.1.2
