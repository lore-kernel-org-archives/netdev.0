From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] team: set IFF_SLAVE on team ports
Date: Thu, 9 Jul 2015 12:07:27 +0200
Message-ID: <20150709100727.GE2270@nanopsycho.orion>
References: <1436435914-8903-1-git-send-email-jblunck@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Blunck <jblunck@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436435914-8903-1-git-send-email-jblunck@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Jul 09, 2015 at 11:58:34AM CEST, jblunck@infradead.org wrote:
>The code in net/ipv6/addrconf.c:addrconf_notify() tests for IFF_SLAVE to
>decide if it should start the address configuration. Since team ports
>shouldn't get link-local addresses assigned lets set IFF_SLAVE when linking
>a port to the team master.

I don't want to use IFF_SLAVE in team. Other master-slave devices are
not using that as well, for example bridge, ovs, etc.

I think that this should be fixed in addrconf_notify. It should lookup
if there is a master on top and bail out in that case.


>
>Signed-off-by: Jan Blunck <jblunck@infradead.org>
>---
> drivers/net/team/team.c | 2 ++
> 1 file changed, 2 insertions(+)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index daa054b..4cd02c8 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1086,6 +1086,7 @@ static int team_upper_dev_link(struct net_device *dev,
> 	err = netdev_master_upper_dev_link(port_dev, dev);
> 	if (err)
> 		return err;
>+	port_dev->flags |= IFF_SLAVE;
> 	port_dev->priv_flags |= IFF_TEAM_PORT;
> 	return 0;
> }
>@@ -1094,6 +1095,7 @@ static void team_upper_dev_unlink(struct net_device *dev,
> 				  struct net_device *port_dev)
> {
> 	netdev_upper_dev_unlink(port_dev, dev);
>+	port_dev->flags &= ~IFF_SLAVE;
> 	port_dev->priv_flags &= ~IFF_TEAM_PORT;
> }
> 
>-- 
>2.1.4
>
