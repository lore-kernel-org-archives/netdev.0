From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH v3] sctp: Implement quick failover draft from tsvwg
Date: Fri, 20 Jul 2012 13:51:39 -0300
Message-ID: <20120720135139.34f2c8c9@obelix.rh>
References: <1342203998-24037-1-git-send-email-nhorman@tuxdriver.com>
	<1342716704-6532-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, joe@perches.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539Ab2GTQwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 12:52:06 -0400
In-Reply-To: <1342716704-6532-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jul 2012 12:51:44 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:
[...]
>  
> +pf_retrans - INTEGER
> +	The number of retransmissions that will be attempted on a given path
> +	before traffic is redirected to an alternate transport (should one
> +	exist).  Note this is distinct from path_max_retrans, as a path that
> +	passes the pf_retrans threshold can still be used.  Its only
> +	deprioritized when a transmission path is selected by the stack.  This
> +	setting is primarily used to enable fast failover mechanisms without
> +	having to reduce path_max_retrans to a very low value.  See:
> +	http://www.ietf.org/id/draft-nishida-tsvwg-sctp-failover-05.txt
> +	for details.  Note also that a value of pf_retrans > path_max_retrans
> +	disables this feature
> +
> +	Default: 0
> +
>  rto_initial - INTEGER
[...]
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index e4652fe..f70726c 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -160,6 +160,7 @@ extern struct sctp_globals {
>  	int max_retrans_association;
>  	int max_retrans_path;
>  	int max_retrans_init;
> +	int pf_retrans;

[...]
>  
> +	/* This is the partially failed retrans value for the transport
> +	 * and will be initialized from the assocs value.  This can be changed
> +	 * using the SCTP_PEER_ADDR_THLDS socket option
> +	 */
> +	int pf_retrans;
>  	/* PMTU	      : The current known path MTU.  */
>  	__u32 pathmtu;
>  
> @@ -1660,6 +1667,8 @@ struct sctp_association {
>  	 */
>  	int max_retrans;
>  
> +	int pf_retrans;
> +


You've documented in one place, but not in the others.  I suggest to include
references like this
       /* See the description in struct sctp_transport */
at the two missing places.

Nice feature,
fbl
