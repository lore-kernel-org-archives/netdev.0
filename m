From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 5/5] sctp: Adjust one function call together with a
 variable assignment
Date: Mon, 22 May 2017 17:00:59 -0400
Message-ID: <44ba1b0c-8987-8710-a9eb-f13ad31bd966@redhat.com>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
 <197333e8-b528-ef34-bd16-01e415acdf52@users.sourceforge.net>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762692AbdEVVBH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 17:01:07 -0400
In-Reply-To: <197333e8-b528-ef34-bd16-01e415acdf52@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 12:41 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 18:15:12 +0200
> 
> The script "checkpatch.pl" pointed information out like the following.
> 
> ERROR: do not use assignment in if condition
> 
> Thus fix the affected source code place.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/sctp/protocol.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 057479b7bd72..be2fe3ebae78 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -141,7 +141,8 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
>  	struct sctp_sockaddr_entry *addr;
>  
>  	rcu_read_lock();
> -	if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
> +	in_dev = __in_dev_get_rcu(dev);
> +	if (!in_dev) {
>  		rcu_read_unlock();
>  		return;
>  	}
> 

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
