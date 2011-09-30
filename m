From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC patch net-next-2.6] net: introduce ethernet teaming device
Date: Fri, 30 Sep 2011 09:26:19 -0700
Message-ID: <20110930092619.6b45087d@nehalam.linuxnetplumber.net>
References: <1317386643-3041-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	fubar@us.ibm.com, andy@greyhouse.net, tgraf@infradead.org,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42876 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab1I3Q0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 12:26:22 -0400
In-Reply-To: <1317386643-3041-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Sep 2011 14:44:03 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> +static struct rtnl_link_stats64 *team_get_stats(struct net_device *dev,
> +						struct rtnl_link_stats64 *stats)
> +{
> +	struct team *team = netdev_priv(dev);
> +	struct rtnl_link_stats64 temp;
> +	struct team_port *port;
> +
> +	memset(stats, 0, sizeof(*stats));
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(port, &team->port_list, list) {
> +		const struct rtnl_link_stats64 *pstats;

You need to use u64_stats_sync macros to make this safe on 32 bit
mode.

Also, I am not sure about the handling of speed and duplex.
There are people who do active backup with links of different speeds.

The team device doesn't seem to handle hardware offload features
as completely as it should.  The TSO and transmit checksumming should
be the union of the teamed ports.
