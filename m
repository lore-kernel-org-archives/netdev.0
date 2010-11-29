From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] vmxnet3: fix compilation when RSS is disabled
Date: Sun, 28 Nov 2010 19:07:31 -0800
Message-ID: <4CF318F3.7040600@oracle.com>
References: <1290890035-32285-1-git-send-email-scottjg@vmware.com> <1290890035-32285-2-git-send-email-scottjg@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, pv-drivers@vmware.com
To: "Scott J. Goldman" <scottjg@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290890035-32285-2-git-send-email-scottjg@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/27/10 12:33, Scott J. Goldman wrote:
> If RSS is disabled, we can ifdef out some RSS specific code. This fixes
> the compile error found by Randy Dunlap.
> 
> Signed-off-by: Scott J. Goldman <scottjg@vmware.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
>  drivers/net/vmxnet3/vmxnet3_ethtool.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> index 9ddaea6..8e17fc8 100644
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> @@ -553,7 +553,7 @@ vmxnet3_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info,
>  	return -EOPNOTSUPP;
>  }
>  
> -
> +#ifdef VMXNET3_RSS
>  static int
>  vmxnet3_get_rss_indir(struct net_device *netdev,
>  		      struct ethtool_rxfh_indir *p)
> @@ -598,6 +598,7 @@ vmxnet3_set_rss_indir(struct net_device *netdev,
>  	return 0;
>  
>  }
> +#endif
>  
>  static struct ethtool_ops vmxnet3_ethtool_ops = {
>  	.get_settings      = vmxnet3_get_settings,
> @@ -623,8 +624,10 @@ static struct ethtool_ops vmxnet3_ethtool_ops = {
>  	.get_ringparam     = vmxnet3_get_ringparam,
>  	.set_ringparam     = vmxnet3_set_ringparam,
>  	.get_rxnfc         = vmxnet3_get_rxnfc,
> +#ifdef VMXNET3_RSS
>  	.get_rxfh_indir    = vmxnet3_get_rss_indir,
>  	.set_rxfh_indir    = vmxnet3_set_rss_indir,
> +#endif
>  };
>  
>  void vmxnet3_set_ethtool_ops(struct net_device *netdev)


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
