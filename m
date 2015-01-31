From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: sctp: Deletion of an unnecessary check before the
 function call "kfree"
Date: Sat, 31 Jan 2015 13:38:53 -0500
Message-ID: <20150131183853.GB24821@localhost.localdomain>
References: <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
 <54CD0DCF.9020804@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54CD0DCF.9020804@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 31, 2015 at 06:15:59PM +0100, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 31 Jan 2015 18:10:03 +0100
> 
> The kfree() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/sctp/associola.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index f791edd..3c2aefc 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -391,8 +391,7 @@ void sctp_association_free(struct sctp_association *asoc)
>  	sctp_asconf_queue_teardown(asoc);
>  
>  	/* Free pending address space being deleted */
> -	if (asoc->asconf_addr_del_pending != NULL)
> -		kfree(asoc->asconf_addr_del_pending);
> +	kfree(asoc->asconf_addr_del_pending);
>  
>  	/* AUTH - Free the endpoint shared keys */
>  	sctp_auth_destroy_keys(&asoc->endpoint_shared_keys);
> -- 
> 2.2.2
> 
> 
Sure, seems reasonable
Acked-By: Neil Horman <nhorman@tuxdriver.com>
