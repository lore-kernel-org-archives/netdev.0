From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: fix poll_controller method so that proper
 structures are passed and all rx queues are checked
Date: Tue, 11 Nov 2008 09:59:24 -0800
Message-ID: <1226426364.23218.14.camel@HP1>
References: <20081111140055.GA30481@hmsreliant.think-freely.org>
 <C27F8246C663564A84BB7AB343977242151F4B18B9@IRVEXCHCCR01.corp.ad.broadcom.com>
 <20081111164634.GB30481@hmsreliant.think-freely.org>
 <1226423350.23218.9.camel@HP1>
 <20081111173708.GC30481@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"'davem@davemloft.net'" <davem@davemloft.net>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1741 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526AbYKKSCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 13:02:10 -0500
In-Reply-To: <20081111173708.GC30481@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-11-11 at 09:37 -0800, Neil Horman wrote:
> Copy that.  Here you go, followon patch to change how we pass the irq vector to
> bnx2_interrupt.  Doesn't do anything super-usefull, but good for the sake of
> correctness

Sorry, I missed something earlier.  After looking at this more closely,
we should also move disable_irq() into the loop and call it with the
same vector values from irq_tbl.

Thanks.
> 
> Regards
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  bnx2.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 9e1f0e3..cad8b7a 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -7208,7 +7208,7 @@ poll_bnx2(struct net_device *dev)
>  
>         disable_irq(bp->pdev->irq);
>         for (i = 0; i < bp->irq_nvecs; i++)
> -               bnx2_interrupt(bp->pdev->irq, &bp->bnx2_napi[i]);
> +               bnx2_interrupt(bp->irq_tbl[i].vector, &bp->bnx2_napi[i]);
>         enable_irq(bp->pdev->irq);
>  }
>  #endif


