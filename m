From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] team: team should sync the port's uc/mc addrs when
 add a port
Date: Mon, 28 Mar 2016 13:49:21 -0300
Message-ID: <20160328164921.GA26741@mrl.redhat.com>
References: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
	Jiri Pirko <jiri@resnulli.us>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524AbcC1QtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 12:49:24 -0400
Content-Disposition: inline
In-Reply-To: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 12:42:31AM +0800, Xin Long wrote:
> There is an issue when we use mavtap over team:
> When we replug nic links from team0, the real nics's mc list will not
> include the maddr for macvtap any more. then we can't receive pkts to
> macvtap device, as they are filterred by mc list of nic.
> 
> In Bonding Driver, it syncs the uc/mc addrs in bond_enslave().
> 
> We will fix this issue on team by adding the port's uc/mc addrs sync in
> team_port_add.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  drivers/net/team/team.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 26c64d2..17ff367 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1198,6 +1198,9 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
>  		goto err_dev_open;
>  	}
>  
> +	dev_uc_sync_multiple(port_dev, dev);
> +	dev_mc_sync_multiple(port_dev, dev);
> +
>  	err = vlan_vids_add_by_dev(port_dev, dev);
>  	if (err) {
>  		netdev_err(dev, "Failed to add vlan ids to device %s\n",
> -- 
> 2.1.0
> 
