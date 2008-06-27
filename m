From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/4] qla3xxx: Hold RTNL while calling dev_close()
Date: Fri, 27 Jun 2008 01:32:24 -0400
Message-ID: <48647B68.3010708@pobox.com>
References: <20080506182654.GF2217@solarflare.com> <20080506183626.GH2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ron Mercer <linux-driver@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56655 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028AbYF0Fc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:32:28 -0400
In-Reply-To: <20080506183626.GH2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> dev_close() must be called holding the RTNL.  Compile-tested only.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/qla3xxx.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
> index b7f7b22..bccee68 100644
> --- a/drivers/net/qla3xxx.c
> +++ b/drivers/net/qla3xxx.c
> @@ -3701,7 +3701,9 @@ static int ql_cycle_adapter(struct ql3_adapter *qdev, int reset)
>  		printk(KERN_ERR PFX
>  				"%s: Driver up/down cycle failed, "
>  				"closing device\n",qdev->ndev->name);
> +		rtnl_lock();
>  		dev_close(qdev->ndev);
> +		rtnl_unlock();
>  		return -1;

applied


