From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next] bonding: don't allow the master to become its slave
Date: Thu, 9 Aug 2012 20:03:23 +0100
Message-ID: <1344539003.2593.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344537049-11473-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Leonardo Chiquitto <lchiquitto@suse.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11172 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759066Ab2HITD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 15:03:27 -0400
In-Reply-To: <1344537049-11473-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-09 at 15:30 -0300, Flavio Leitner wrote:
> It doesn't make any sense to allow the master to become
> its slave. That creates a loop of events causing a crash.

What if there are other intermediate devices, e.g. the slave is a VLAN
sub-device of the bond?  And doesn't team also have this problem?

I think a more general check for such loops might be required.

Ben.

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
> @@ -1505,6 +1505,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
