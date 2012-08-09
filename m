From: "Leonardo Chiquitto" <lchiquitto@suse.com>
Subject: Re: [net-next] bonding: don't allow the master to become its
 slave
Date: Thu, 09 Aug 2012 12:45:15 -0600
Message-ID: <5023DB0B02000086000C9D31@novprvoes0310.provo.novell.com>
References: <1344537049-11473-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Andy Gospodarek" <andy@greyhouse.net>,
	"Jay Vosburgh" <fubar@us.ibm.com>
To: "Flavio Leitner" <fbl@redhat.com>,
	"netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from novprvoes0310.provo.novell.com ([137.65.248.74]:36588 "EHLO
	novprvoes0310.provo.novell.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759206Ab2HITFF convert rfc822-to-8bit
	(ORCPT <rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Thu, 9 Aug 2012 15:05:05 -0400
In-Reply-To: <1344537049-11473-1-git-send-email-fbl@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 8/9/2012 at 03:30 PM, Flavio Leitner <fbl@redhat.com> wrote: 
> It doesn't make any sense to allow the master to become
> its slave. That creates a loop of events causing a crash.
> 
> Reported-by: Leonardo Chiquitto <lchiquitto@suse.com>
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 6fae5f3..5407b44 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1505,6 +1505,11 @@ int bond_enslave(struct net_device *bond_dev, struct 
> net_device *slave_dev)
>  	int link_reporting;
>  	int res = 0;
>  
> +	if (bond_dev == slave_dev) {
> +		pr_err("%s: Error: cannot enslave itself.\n", bond_dev->name);
> +		return -EINVAL;
> +	}
> +
>  	if (!bond->params.use_carrier && slave_dev->ethtool_ops == NULL &&
>  		slave_ops->ndo_do_ioctl == NULL) {
>  		pr_warning("%s: Warning: no link monitoring support for %s\n",

I've tested it here and confirm it prevents the crash.

Tested-by: Leonardo Chiquitto <lchiquitto@suse.com>

Thanks,
Leonardo
